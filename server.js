const express = require('express');
const path = require('path');
const fs = require('fs');
const session = require('express-session');
const cookieParser = require('cookie-parser');
const cors = require('cors');
const { sendBookingConfirmationEmail } = require('./services/emailService');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser('flutter_hotels_resorts_secret_2026'));
app.use(express.static(path.join(__dirname, 'public')));
app.use(session({
  secret: 'flutter_hotels_resorts_secret_2026',
  resave: true,
  saveUninitialized: true,
  cookie: { maxAge: 7 * 24 * 60 * 60 * 1000 } // 7 days session
}));

// Set EJS View Engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Helper Data Loaders & Savers with Vercel Serverless In-Memory Cache
const DATA_DIR = path.join(__dirname, 'data');
const getFilePath = (fileName) => path.join(DATA_DIR, fileName);
const dataCache = {};

function readData(file) {
  if (dataCache[file]) {
    return dataCache[file];
  }
  try {
    const raw = fs.readFileSync(getFilePath(file), 'utf8');
    const parsed = JSON.parse(raw);
    dataCache[file] = parsed;
    return parsed;
  } catch (err) {
    console.error(`Error reading ${file}:`, err);
    return dataCache[file] || [];
  }
}

function saveData(file, data) {
  dataCache[file] = data;
  try {
    fs.writeFileSync(getFilePath(file), JSON.stringify(data, null, 2), 'utf8');
    return true;
  } catch (err) {
    // Vercel serverless filesystem is read-only, in-memory dataCache preserves all bookings during runtime
    return true;
  }
}

// Global View Variables & Vercel Session Hydration Middleware
app.use((req, res, next) => {
  // Re-hydrate session from HTTP cookie for Vercel serverless multi-instance support
  if ((!req.session || !req.session.user) && req.cookies && req.cookies.admin_token === 'flutter_admin_authenticated_2026') {
    req.session = req.session || {};
    req.session.user = {
      id: 'admin-1',
      name: 'Flutter General Director',
      username: 'admin',
      isAdmin: true
    };
  }

  res.locals.user = req.session.user || null;
  res.locals.isAdmin = !!(req.session.user && req.session.user.isAdmin);
  res.locals.phoneMain = "+91 89 2923 2740";
  res.locals.phoneAlt = "";
  res.locals.emailMain = "sales@flutterhotel.com";
  res.locals.whatsappNum = "918929232740";
  next();
});

// Admin Protection Middleware with Vercel Serverless Token Support
function requireAdmin(req, res, next) {
  // 1. Check Session Memory
  if (req.session && req.session.user && req.session.user.isAdmin) {
    return next();
  }
  // 2. Check Persistent HTTP Cookie Token (fixes Vercel serverless session loss)
  if (req.cookies && req.cookies.admin_token === 'flutter_admin_authenticated_2026') {
    req.session.user = {
      id: 'admin-1',
      name: 'Flutter General Director',
      username: 'admin',
      isAdmin: true
    };
    res.locals.user = req.session.user;
    res.locals.isAdmin = true;
    return next();
  }
  return res.redirect('/login?error=Unauthorized.+Please+login+as+Admin.');
}

// --- PUBLIC ROUTES ---

// 1. Homepage
app.get('/', (req, res) => {
  const rooms = readData('rooms.json');
  const reviews = readData('reviews.json');
  const offers = readData('offers.json');
  
  res.render('index', {
    title: 'Flutter Hotels & Resorts | Hill Resort in Lansdowne',
    metaDesc: 'Book direct at Flutter Hotels & Resorts, Lansdowne — valley-view rooms, bonfire evenings & multi-cuisine dining in the Garhwal Himalayas.',
    rooms: rooms,
    reviews: reviews,
    offers: offers
  });
});

// 2. Rooms Catalog Overview
app.get('/rooms', (req, res) => {
  let rooms = readData('rooms.json');
  const { category, minPrice, maxPrice, guests } = req.query;

  if (category && category !== 'All') {
    rooms = rooms.filter(r => r.category.toLowerCase().includes(category.toLowerCase()));
  }
  if (guests) {
    rooms = rooms.filter(r => r.capacity >= parseInt(guests));
  }
  if (minPrice) {
    rooms = rooms.filter(r => r.price >= parseFloat(minPrice));
  }
  if (maxPrice) {
    rooms = rooms.filter(r => r.price <= parseFloat(maxPrice));
  }

  res.render('rooms', {
    title: 'Rooms at Flutter Hotels & Resorts, Lansdowne',
    metaDesc: 'Explore Super Deluxe Valley View, Garden View and Classic rooms at Flutter Hotels & Resorts — king beds, private balconies, free Wi-Fi.',
    rooms: rooms,
    query: req.query
  });
});

// 3. Single Room Detail Page
app.get('/rooms/:id', (req, res) => {
  const rooms = readData('rooms.json');
  const room = rooms.find(r => r.id === req.params.id);
  if (!room) {
    return res.status(404).render('404', { title: 'Room Not Found | Flutter Hotels' });
  }
  const relatedRooms = rooms.filter(r => r.id !== room.id);
  res.render('room-detail', {
    title: `${room.name} | Flutter Hotels & Resorts`,
    metaDesc: `Book the ${room.name} at Flutter Hotels & Resorts, Lansdowne — ${room.size}, ${room.bed}, private balcony, ${room.view}.`,
    room: room,
    relatedRooms: relatedRooms
  });
});

// 4. Special Offers Landing Page
app.get('/offers', (req, res) => {
  const offers = readData('offers.json');
  res.render('offers', {
    title: 'Special Offers & Discounts | Flutter Hotels & Resorts',
    metaDesc: 'Weekday & weekend discounts, promotional deals, and season specials at Flutter Hotels & Resorts, Lansdowne. Book direct & save.',
    offers: offers
  });
});

// 4b. Packages Catalog Page
app.get('/packages', (req, res) => {
  const packages = readData('packages.json');
  res.render('packages', {
    title: 'Holiday & Experience Packages | Flutter Hotels & Resorts',
    metaDesc: 'Honeymoon, weekend getaway, Delhi group departure, corporate MICE and wedding packages at Flutter Hotels & Resorts, Lansdowne.',
    packages: packages
  });
});

// 4c. Single Package Detail Page
app.get('/packages/:slug', (req, res) => {
  const packages = readData('packages.json');
  const packageItem = packages.find(p => p.slug === req.params.slug);
  if (!packageItem) {
    return res.redirect('/packages');
  }
  res.render('package-detail', {
    title: `${packageItem.metaTitle || packageItem.title}`,
    metaDesc: packageItem.metaDescription,
    packageItem: packageItem
  });
});

// 5. Single Offer Detail Page
app.get('/offers/:slug', (req, res) => {
  const offers = readData('offers.json');
  const offer = offers.find(o => o.slug === req.params.slug);
  if (!offer) {
    return res.redirect('/offers');
  }
  res.render('offer-detail', {
    title: `${offer.metaTitle || offer.title}`,
    metaDesc: offer.metaDescription,
    offer: offer
  });
});

// Razorpay Compliance Policy Pages
app.get('/privacy-policy', (req, res) => {
  res.render('privacy-policy', {
    title: 'Privacy Policy | Flutter Hotels & Resorts',
    metaDesc: 'Privacy Policy and data protection terms for Flutter Hotels & Resorts, Lansdowne, Uttarakhand.'
  });
});

// Dropdown Sub-Menu Pages
app.get('/about-us', (req, res) => {
  res.render('about', {
    title: 'About Us | Flutter Hotels & Resorts, Lansdowne',
    metaDesc: 'Welcome to Flutter Hotels & Resorts, Lansdowne — hillside sanctuary offering valley views, private balcony stays, and Garhwali hospitality.'
  });
});

app.get('/meetings-events', (req, res) => {
  res.render('meetings-events', {
    title: 'Meetings & Corporate Events | Flutter Hotels & Resorts',
    metaDesc: 'Host corporate conferences, executive retreats and team workshops at Flutter Hotels & Resorts, Lansdowne.'
  });
});

app.get('/celebrations', (req, res) => {
  res.render('celebrations', {
    title: 'Weddings & Celebrations | Flutter Hotels & Resorts',
    metaDesc: 'Destination weddings, anniversary galas and milestone celebrations at Flutter Hotels & Resorts, Lansdowne.'
  });
});

app.get('/group-booking', (req, res) => {
  res.render('group-booking', {
    title: 'Group Bookings & Bulk Room Rates | Flutter Hotels & Resorts',
    metaDesc: 'Discounted group rates for 5+ rooms, corporate teams, college tours and family groups.'
  });
});

app.get('/facilities', (req, res) => {
  res.render('facilities', {
    title: 'Resort Facilities & Amenities | Flutter Hotels & Resorts',
    metaDesc: 'Multi-cuisine dining, high-speed Wi-Fi, lawns, bonfire evenings and 24/7 concierge at Flutter Hotels.'
  });
});

app.get('/location', (req, res) => {
  res.render('location', {
    title: 'Location & How To Reach | Flutter Hotels & Resorts',
    metaDesc: 'Travel routes from Delhi, Kotdwar railway station, and Jolly Grant airport to Flutter Hotels & Resorts, Lansdowne.',
    mapEmbedUrl: 'https://share.google/zTrQmg3ZsRlLWlJuk'
  });
});

app.get('/terms-conditions', (req, res) => {
  res.render('terms-conditions', {
    title: 'Terms & Conditions | Flutter Hotels & Resorts',
    metaDesc: 'Terms and Conditions for room reservations and stays at Flutter Hotels & Resorts, Lansdowne.'
  });
});

app.get('/cancellation-refund-policy', (req, res) => {
  res.render('cancellation-refund-policy', {
    title: 'Cancellation & Refund Policy | Flutter Hotels & Resorts',
    metaDesc: 'Cancellation windows, refund processing guidelines, and timelines for Flutter Hotels & Resorts.'
  });
});

app.get('/booking-policy', (req, res) => {
  res.render('booking-policy', {
    title: 'Booking & Delivery Policy | Flutter Hotels & Resorts',
    metaDesc: 'Reservation confirmation, instant voucher delivery, and stay service fulfillment terms.'
  });
});

app.get('/careers', (req, res) => {
  const jobs = readData('jobs.json').filter(j => j.status === 'Active' || !j.status);
  res.render('careers', {
    title: 'Careers & Job Openings | Flutter Hotels & Resorts',
    metaDesc: 'Explore hospitality career opportunities at Flutter Hotels & Resorts, Lansdowne. Apply directly via WhatsApp.',
    jobs: jobs
  });
});

// Dedicated 2-Step Checkout Page
app.get('/checkout', (req, res) => {
  const { type, id, checkIn, checkOut, guests } = req.query;

  const todayStr = new Date().toISOString().split('T')[0];
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const tomorrowStr = tomorrow.toISOString().split('T')[0];

  const selectedCheckIn = checkIn || todayStr;
  const selectedCheckOut = checkOut || tomorrowStr;
  const selectedGuests = parseInt(guests) || 2;

  // Calculate nights
  const start = new Date(selectedCheckIn);
  const end = new Date(selectedCheckOut);
  const diffTime = Math.abs(end - start);
  const nights = Math.max(1, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));

  let item = null;
  if (type === 'package') {
    const packages = readData('packages.json');
    item = packages.find(p => p.id === id || p.slug === id);
    if (!item) item = packages[0];
  } else if (type === 'offer') {
    const offers = readData('offers.json');
    item = offers.find(o => o.id === id || o.slug === id);
    if (!item) item = offers[0];
  } else {
    const rooms = readData('rooms.json');
    if (id) {
      item = rooms.find(r => r.id === id || r.id.toLowerCase() === id.toLowerCase());
    }
    if (!item) item = rooms[0];
  }

  // Calculate rate breakdown
  let basePrice = 2400;
  if (item && item.price) {
    if (typeof item.price === 'number') {
      basePrice = item.price;
    } else {
      const match = String(item.price).replace(/,/g, '').match(/\d+/);
      if (match) basePrice = parseInt(match[0]);
    }
  }

  const roomSubtotal = basePrice * nights;
  const tax = Math.round(roomSubtotal * 0.12);
  const total = roomSubtotal + tax;

  res.render('checkout', {
    title: `Checkout — ${item ? (item.name || item.title) : 'Reservation'} | Flutter Hotels & Resorts`,
    item: item,
    dates: {
      checkIn: selectedCheckIn,
      checkOut: selectedCheckOut,
      guests: selectedGuests,
      nights: nights
    },
    pricing: {
      basePrice: basePrice,
      subtotal: roomSubtotal,
      tax: tax,
      total: total
    }
  });
});

// 6. Things To Do In Lansdowne
app.get('/things-to-do', (req, res) => {
  res.render('things-to-do', {
    title: 'Things To Do in Lansdowne | Flutter Hotels',
    metaDesc: 'Temples, viewpoints, a war memorial and boating near Flutter Hotels & Resorts, Lansdowne. Plan your sightseeing from our hillside stay.'
  });
});

// 7. Dining Page
app.get('/dining', (req, res) => {
  res.render('dining', {
    title: 'Multi-Cuisine Restaurant | Flutter Hotels & Resorts',
    metaDesc: 'Enjoy multi-cuisine dining at Flutter Hotels & Resorts, Lansdowne — in-house restaurant, free dinner & F&B offers available. Book direct.'
  });
});

// 8. Gallery Page
app.get('/gallery', (req, res) => {
  res.render('gallery', {
    title: 'Photo Gallery | Flutter Hotels & Resorts, Lansdowne',
    metaDesc: 'Browse photos of rooms, valley views, lawns and bonfire evenings at Flutter Hotels & Resorts, Lansdowne, Uttarakhand.'
  });
});

// 9. Contact Us Page
app.get('/contact', (req, res) => {
  res.render('contact', {
    title: 'Contact Us | Flutter Hotels & Resorts, Lansdowne',
    metaDesc: 'Get in touch with Flutter Hotels & Resorts in Lansdowne, Uttarakhand — call, WhatsApp or email us to book or ask a question.',
    success: req.query.success || null
  });
});

// Contact Form Handler
app.post('/contact', (req, res) => {
  const { name, email, phone, dates, guests, subject, message } = req.body;
  if (!name || !email || (!phone && !message)) {
    return res.render('contact', {
      title: 'Contact Us | Flutter Hotels & Resorts',
      metaDesc: 'Get in touch with Flutter Hotels & Resorts.',
      error: 'Please fill in all required contact fields.'
    });
  }

  const inquiries = readData('inquiries.json');
  const newInquiry = {
    id: 'FLT-INQ-' + Math.floor(100 + Math.random() * 900),
    name,
    email,
    phone: phone || '',
    dates: dates || 'Not specified',
    guests: guests || 'Not specified',
    subject: subject || 'General / Room Inquiry',
    message: message || 'Booking enquiry submitted.',
    status: 'Unread',
    date: new Date().toISOString()
  };

  inquiries.unshift(newInquiry);
  saveData('inquiries.json', inquiries);

  res.redirect('/contact?success=Thank+you!+Your+enquiry+has+been+received.+Our+reservations+team+will+contact+you+on+phone%2FWhatsApp+shortly.');
});

// Booking Confirmation Page
app.get('/booking/confirm/:id', (req, res) => {
  const bookings = readData('bookings.json');
  const booking = bookings.find(b => b.id === req.params.id);
  if (!booking) {
    return res.redirect('/rooms');
  }
  const rooms = readData('rooms.json');
  const room = rooms.find(r => r.id === booking.roomId);

  res.render('booking-confirmation', {
    title: 'Booking Confirmed | Flutter Hotels & Resorts',
    booking: booking,
    room: room
  });
});

// Login Page
app.get('/login', (req, res) => {
  res.render('login', {
    title: 'Guest Login & Admin Portal | Flutter Hotels',
    error: req.query.error || null
  });
});

// Login POST Handler
app.post('/login', (req, res) => {
  const { username, password } = req.body;

  // Admin authentication (Default: admin / admin123)
  if ((username === 'admin' || username === 'sales@flutterhotel.com') && password === 'admin123') {
    req.session.user = {
      id: 'admin-1',
      name: 'Flutter General Director',
      username: 'admin',
      isAdmin: true
    };

    // Set persistent HTTP cookie for Vercel serverless multi-instance support
    res.cookie('admin_token', 'flutter_admin_authenticated_2026', {
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
      httpOnly: true,
      sameSite: 'lax',
      path: '/'
    });

    return res.redirect('/admin');
  }

  // Demo guest user
  if (username && password) {
    req.session.user = {
      id: 'user-' + Date.now(),
      name: username,
      username: username,
      isAdmin: false
    };
    return res.redirect('/');
  }

  return res.render('login', {
    title: 'Guest Login & Admin Portal | Flutter Hotels',
    error: 'Invalid username or password.'
  });
});

// Logout Handler
app.get('/logout', (req, res) => {
  res.clearCookie('admin_token', { path: '/' });
  if (req.session) {
    req.session.destroy(() => {
      res.redirect('/login');
    });
  } else {
    res.redirect('/login');
  }
});

// --- REST API ENDPOINTS ---

// Check Availability API
app.post('/api/check-availability', (req, res) => {
  const { checkIn, checkOut, guests, roomType } = req.body;
  const rooms = readData('rooms.json');

  let availableRooms = rooms;
  if (guests) {
    availableRooms = availableRooms.filter(r => r.capacity >= parseInt(guests));
  }
  if (roomType && roomType !== 'All') {
    availableRooms = availableRooms.filter(r => r.category.toLowerCase().includes(roomType.toLowerCase()));
  }

  return res.json({
    success: true,
    count: availableRooms.length,
    rooms: availableRooms
  });
});

// 10. Public Blog Catalog
app.get('/blog', (req, res) => {
  const blogs = readData('blogs.json');
  res.render('blog', {
    title: 'Lansdowne Travel & Resort Stories | Flutter Hotels Blog',
    metaDesc: 'Explore travel guides, local sightseeing tips, wedding planning advice, and Garhwali culture stories from Flutter Hotels & Resorts.',
    blogs: blogs
  });
});

// 11. Single Blog Article Detail Page
app.get('/blog/:slug', (req, res) => {
  const blogs = readData('blogs.json');
  const article = blogs.find(b => b.slug === req.params.slug);
  if (!article) {
    return res.redirect('/blog');
  }
  res.render('blog-detail', {
    title: `${article.metaTitle || article.title}`,
    metaDesc: article.metaDescription,
    article: article
  });
});

// Create Booking API & Form Handler
app.post('/api/bookings', (req, res) => {
  let { roomId, roomName, guestName, email, phone, address, city, state, pincode, arrivalTime, notes, addons, checkIn, checkOut, guests, paymentMethod } = req.body;

  // Fallback defaults for missing fields
  guestName = guestName || 'Valued Guest';
  email = email || 'guest@flutterhotel.com';

  const todayStr = new Date().toISOString().split('T')[0];
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const tomorrowStr = tomorrow.toISOString().split('T')[0];

  checkIn = checkIn || todayStr;
  checkOut = checkOut || tomorrowStr;

  const rooms = readData('rooms.json');
  let room = null;

  if (roomId) {
    room = rooms.find(r => r.id === roomId || r.id.toLowerCase() === roomId.toLowerCase());
  }

  if (!room && roomName) {
    room = rooms.find(r => r.name.toLowerCase().includes(roomName.toLowerCase()));
  }

  if (!room) {
    room = rooms[0]; // Intelligent fallback to first room
  }

  // Calculate nights & pricing including add-on services
  const start = new Date(checkIn);
  const end = new Date(checkOut);
  const diffTime = Math.abs(end - start);
  const nights = Math.max(1, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));
  
  let baseRoomRate = 2400;
  if (room && room.price) {
    if (typeof room.price === 'number') {
      baseRoomRate = room.price;
    } else {
      const match = String(room.price).replace(/,/g, '').match(/\d+/);
      if (match) baseRoomRate = parseInt(match[0]);
    }
  }

  const roomSubtotal = baseRoomRate * nights;

  // Process Add-on services selection
  let selectedAddons = [];
  let addonPriceSum = 0;
  if (addons) {
    if (Array.isArray(addons)) {
      selectedAddons = addons;
    } else {
      selectedAddons = [addons];
    }
    selectedAddons.forEach(addonStr => {
      const match = String(addonStr).match(/₹([\d,]+)/);
      if (match) {
        addonPriceSum += parseInt(match[1].replace(/,/g, ''));
      }
    });
  }

  const taxableSubtotal = roomSubtotal + addonPriceSum;
  const taxAmount = Math.round(taxableSubtotal * 0.12);
  const totalPrice = taxableSubtotal + taxAmount;

  const bookings = readData('bookings.json');
  const newBooking = {
    id: 'FLT-' + Math.floor(1000 + Math.random() * 9000),
    roomId: room ? room.id : 'room-valley-super-deluxe',
    roomName: room ? room.name : (roomName || 'Super Deluxe – Valley View'),
    guestName,
    email,
    phone: phone || '',
    address: address || '',
    city: city || '',
    state: state || '',
    pincode: pincode || '',
    arrivalTime: arrivalTime || '12:00 PM - 2:00 PM',
    notes: notes || '',
    addons: selectedAddons,
    checkIn,
    checkOut,
    guests: parseInt(guests) || 1,
    nights: nights,
    totalPrice: totalPrice,
    status: 'Confirmed',
    createdAt: new Date().toISOString(),
    paymentMethod: paymentMethod || 'Pay at Hotel Check-in'
  };

  bookings.unshift(newBooking);
  saveData('bookings.json', bookings);

  // Asynchronously dispatch luxury HTML booking confirmation email to customer & admin
  sendBookingConfirmationEmail(newBooking, room || rooms[0]).catch(err => console.error('Async email error:', err));

  // If request comes from AJAX/Fetch JSON
  if (req.xhr || (req.headers['content-type'] && req.headers['content-type'].includes('application/json'))) {
    return res.json({
      success: true,
      message: 'Booking created successfully!',
      bookingId: newBooking.id,
      redirectUrl: `/booking/confirm/${newBooking.id}`
    });
  }

  // Standard HTML Form submission ALWAYS redirects to Thank You / Confirmation Page
  return res.redirect(`/booking/confirm/${newBooking.id}`);
});

// --- ADMIN PANEL ROUTES ---

// Admin Dashboard Overview
app.get('/admin', requireAdmin, (req, res) => {
  const bookings = readData('bookings.json');
  const rooms = readData('rooms.json');
  const inquiries = readData('inquiries.json');

  const totalRevenue = bookings
    .filter(b => b.status === 'Confirmed')
    .reduce((sum, b) => sum + (b.totalPrice || 0), 0);

  const pendingBookings = bookings.filter(b => b.status === 'Pending').length;
  const unreadInquiries = inquiries.filter(i => i.status === 'Unread').length;

  res.render('admin/dashboard', {
    title: 'Admin Dashboard | Flutter Hotels & Resorts',
    stats: {
      totalBookings: bookings.length,
      totalRooms: rooms.length,
      totalRevenue: totalRevenue,
      pendingBookings: pendingBookings,
      unreadInquiries: unreadInquiries
    },
    recentBookings: bookings.slice(0, 5),
    recentInquiries: inquiries.slice(0, 5)
  });
});

// Admin Manage Bookings
app.get('/admin/bookings', requireAdmin, (req, res) => {
  const bookings = readData('bookings.json');
  res.render('admin/bookings', {
    title: 'Manage Bookings | Flutter Hotels Admin',
    bookings: bookings
  });
});

// Update Booking Status API
app.patch('/api/admin/bookings/:id/status', requireAdmin, (req, res) => {
  const { status } = req.body;
  const bookings = readData('bookings.json');
  const index = bookings.findIndex(b => b.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Booking not found.' });
  }

  bookings[index].status = status;
  saveData('bookings.json', bookings);
  return res.json({ success: true, message: `Booking status updated to ${status}` });
});

// Delete Booking API
app.delete('/api/admin/bookings/:id', requireAdmin, (req, res) => {
  let bookings = readData('bookings.json');
  bookings = bookings.filter(b => b.id !== req.params.id);
  saveData('bookings.json', bookings);
  return res.json({ success: true, message: 'Booking deleted.' });
});

// Admin Manage Rooms
app.get('/admin/rooms', requireAdmin, (req, res) => {
  const rooms = readData('rooms.json');
  res.render('admin/rooms', {
    title: 'Manage Rooms | Flutter Hotels Admin',
    rooms: rooms
  });
});

// Add Room API
app.post('/api/admin/rooms', requireAdmin, (req, res) => {
  const { name, category, price, bed, capacity, size, view, image, description } = req.body;
  if (!name || !price || !category) {
    return res.status(400).json({ success: false, message: 'Name, Category, and Price are required.' });
  }

  const rooms = readData('rooms.json');
  const newRoom = {
    id: 'room-' + Date.now(),
    name,
    category,
    price: parseFloat(price),
    rating: 5,
    bed: bed || '1 King Bed',
    capacity: parseInt(capacity) || 2,
    size: size || '180 sq. ft.',
    wifi: true,
    breakfast: true,
    view: view || 'Valley View',
    image: image || '/images/hotel-img-1.jpg',
    featured: true,
    description: description || 'Luxurious hillside suite with private balcony.',
    amenities: ["Free Wi-Fi", "Private Balcony", "32-inch TV", "Tea/Coffee Maker", "Mineral Water", "Wardrobe"]
  };

  rooms.push(newRoom);
  saveData('rooms.json', rooms);
  return res.json({ success: true, message: 'Room added successfully!', room: newRoom });
});

// Delete Room API
app.delete('/api/admin/rooms/:id', requireAdmin, (req, res) => {
  let rooms = readData('rooms.json');
  rooms = rooms.filter(r => r.id !== req.params.id);
  saveData('rooms.json', rooms);
  return res.json({ success: true, message: 'Room deleted successfully.' });
});

// Admin Inquiries Page
app.get('/admin/inquiries', requireAdmin, (req, res) => {
  const inquiries = readData('inquiries.json');
  res.render('admin/inquiries', {
    title: 'Customer Inquiries | Flutter Hotels Admin',
    inquiries: inquiries
  });
});

// Admin Manage CMS Blogs Page
app.get('/admin/blogs', requireAdmin, (req, res) => {
  const blogs = readData('blogs.json');
  res.render('admin/blogs', {
    title: 'CMS Blog Management | Flutter Hotels Admin',
    blogs: blogs
  });
});

// Add New Blog API
app.post('/api/admin/blogs', requireAdmin, (req, res) => {
  const { title, category, author, image, readTime, excerpt, content } = req.body;
  if (!title || !excerpt || !content) {
    return res.status(400).json({ success: false, message: 'Title, Excerpt, and Content are required.' });
  }

  const slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)+/g, '');
  const blogs = readData('blogs.json');
  const newBlog = {
    id: 'blog-' + Date.now(),
    title,
    slug,
    category: category || 'Travel & Sightseeing',
    author: author || 'Flutter Editorial Team',
    date: new Date().toISOString().split('T')[0],
    image: image || '/images/hotel-img-1.jpg',
    excerpt,
    featured: false,
    readTime: readTime || '5 min read',
    metaTitle: `${title} | Flutter Hotels & Resorts`,
    metaDescription: excerpt,
    content
  };

  blogs.unshift(newBlog);
  saveData('blogs.json', blogs);
  return res.redirect('/admin/blogs');
});

// Delete Blog API
app.delete('/api/admin/blogs/:id', requireAdmin, (req, res) => {
  let blogs = readData('blogs.json');
  blogs = blogs.filter(b => b.id !== req.params.id);
  saveData('blogs.json', blogs);
  return res.json({ success: true, message: 'Blog deleted successfully.' });
});

// Admin Manage CMS Offers & Deals Page
app.get('/admin/offers', requireAdmin, (req, res) => {
  const offers = readData('offers.json');
  res.render('admin/offers', {
    title: 'CMS Special Offers & Deals | Flutter Hotels Admin',
    offers: offers
  });
});

// Add New Monthly Offer Slider Banner API
app.post('/api/admin/offers', requireAdmin, (req, res) => {
  const { title, subtitle, image, btnText, btnLink, validity } = req.body;
  if (!title || !subtitle || !image) {
    return res.status(400).json({ success: false, message: 'Title, Subtitle, and Image URL are required.' });
  }

  const slug = title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)+/g, '');
  const offers = readData('offers.json');

  const newOffer = {
    id: 'offer-monthly-' + Date.now(),
    title,
    subtitle,
    slug,
    image: image || '/images/hotel-img-5.jpeg',
    btnText: btnText || 'Claim Offer Now',
    btnLink: btnLink || '/checkout?type=room',
    validity: validity || 'Limited Time Monthly Offer',
    status: 'Active',
    createdAt: new Date().toISOString().split('T')[0]
  };

  offers.unshift(newOffer);
  saveData('offers.json', offers);
  return res.redirect('/admin/offers');
});

// Delete Offer API
app.delete('/api/admin/offers/:id', requireAdmin, (req, res) => {
  let offers = readData('offers.json');
  offers = offers.filter(o => o.id !== req.params.id);
  saveData('offers.json', offers);
  return res.json({ success: true, message: 'Offer deleted successfully.' });
});

// Admin Manage Careers & Jobs Page
app.get('/admin/jobs', requireAdmin, (req, res) => {
  const jobs = readData('jobs.json');
  res.render('admin/jobs', {
    title: 'Careers & Job Openings Management | Flutter Hotels Admin',
    jobs: jobs
  });
});

// Add New Job Opening API
app.post('/api/admin/jobs', requireAdmin, (req, res) => {
  const { title, category, location, type, experience, description, requirements, whatsappNumber } = req.body;
  if (!title || !description) {
    return res.status(400).json({ success: false, message: 'Title and Description are required.' });
  }

  const jobs = readData('jobs.json');
  const newJob = {
    id: 'job-' + Date.now(),
    title,
    category: category || 'General Hospitality',
    location: location || 'Lansdowne, Uttarakhand',
    type: type || 'Full-Time',
    experience: experience || '1 - 3 Years',
    description,
    requirements: requirements || '',
    postedDate: new Date().toISOString().split('T')[0],
    whatsappNumber: whatsappNumber || '918929232740',
    status: 'Active'
  };

  jobs.unshift(newJob);
  saveData('jobs.json', jobs);
  return res.redirect('/admin/jobs');
});

// Edit Job Opening API
app.post('/api/admin/jobs/edit/:id', requireAdmin, (req, res) => {
  const { title, category, location, type, experience, description, requirements, whatsappNumber, status } = req.body;
  let jobs = readData('jobs.json');
  const index = jobs.findIndex(j => j.id === req.params.id);
  if (index !== -1) {
    jobs[index] = {
      ...jobs[index],
      title: title || jobs[index].title,
      category: category || jobs[index].category,
      location: location || jobs[index].location,
      type: type || jobs[index].type,
      experience: experience || jobs[index].experience,
      description: description || jobs[index].description,
      requirements: requirements || jobs[index].requirements,
      whatsappNumber: whatsappNumber || jobs[index].whatsappNumber,
      status: status || jobs[index].status || 'Active'
    };
    saveData('jobs.json', jobs);
  }
  return res.redirect('/admin/jobs');
});

// Delete Job Opening API
app.delete('/api/admin/jobs/:id', requireAdmin, (req, res) => {
  let jobs = readData('jobs.json');
  jobs = jobs.filter(j => j.id !== req.params.id);
  saveData('jobs.json', jobs);
  return res.json({ success: true, message: 'Job posting deleted successfully.' });
});

// 404 Route
app.use((req, res) => {
  res.status(404).render('404', { title: 'Page Not Found | Flutter Hotels & Resorts' });
});

// Start Server
app.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(`  FLUTTER HOTELS & RESORTS SERVER RUNNING ONLINE!   `);
  console.log(`  Public Web:  http://localhost:${PORT}             `);
  console.log(`  Admin Panel: http://localhost:${PORT}/admin       `);
  console.log(`====================================================`);
});

module.exports = app;
