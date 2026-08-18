const express = require('express');
const path = require('path');
const fs = require('fs');
const session = require('express-session');
const cors = require('cors');
const { sendBookingConfirmationEmail } = require('./services/emailService');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));
app.use(session({
  secret: 'flutter_hotels_resorts_secret_2026',
  resave: false,
  saveUninitialized: false,
  cookie: { maxAge: 24 * 60 * 60 * 1000 } // 24 hours
}));

// Set EJS View Engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Helper Data Loaders & Savers
const DATA_DIR = path.join(__dirname, 'data');
const getFilePath = (fileName) => path.join(DATA_DIR, fileName);

function readData(file) {
  try {
    const raw = fs.readFileSync(getFilePath(file), 'utf8');
    return JSON.parse(raw);
  } catch (err) {
    console.error(`Error reading ${file}:`, err);
    return [];
  }
}

function saveData(file, data) {
  try {
    fs.writeFileSync(getFilePath(file), JSON.stringify(data, null, 2), 'utf8');
    return true;
  } catch (err) {
    console.error(`Error saving ${file}:`, err);
    return false;
  }
}

// Global View Variables Middleware
app.use((req, res, next) => {
  res.locals.user = req.session.user || null;
  res.locals.isAdmin = req.session.user && req.session.user.isAdmin;
  res.locals.phoneMain = "+91 89 2923 2740";
  res.locals.phoneAlt = "+91 13 8629 9133";
  res.locals.emailMain = "sales@flutterhotel.com";
  res.locals.whatsappNum = "918929232740";
  next();
});

// Admin Protection Middleware
function requireAdmin(req, res, next) {
  if (req.session.user && req.session.user.isAdmin) {
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

// Logout
app.get('/logout', (req, res) => {
  req.session.destroy(() => {
    res.redirect('/');
  });
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

// Create Booking API
app.post('/api/bookings', (req, res) => {
  const { roomId, guestName, email, phone, checkIn, checkOut, guests, paymentMethod } = req.body;

  if (!roomId || !guestName || !email || !checkIn || !checkOut) {
    return res.status(400).json({ success: false, message: 'Missing required booking details.' });
  }

  const rooms = readData('rooms.json');
  const room = rooms.find(r => r.id === roomId);
  if (!room) {
    return res.status(404).json({ success: false, message: 'Selected room not found.' });
  }

  // Calculate nights
  const start = new Date(checkIn);
  const end = new Date(checkOut);
  const diffTime = Math.abs(end - start);
  const nights = Math.max(1, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));
  const totalPrice = room.price * nights;

  const bookings = readData('bookings.json');
  const newBooking = {
    id: 'FLT-' + Math.floor(1000 + Math.random() * 9000),
    roomId: room.id,
    roomName: room.name,
    guestName,
    email,
    phone: phone || '',
    checkIn,
    checkOut,
    guests: parseInt(guests) || 1,
    totalPrice,
    status: 'Confirmed',
    createdAt: new Date().toISOString(),
    paymentMethod: paymentMethod || 'Pay at Hotel Check-in'
  };

  bookings.unshift(newBooking);
  saveData('bookings.json', bookings);

  // Asynchronously dispatch luxury HTML booking confirmation email to customer & admin
  sendBookingConfirmationEmail(newBooking, room).catch(err => console.error('Async email error:', err));

  return res.json({
    success: true,
    message: 'Booking created successfully!',
    bookingId: newBooking.id,
    redirectUrl: `/booking/confirm/${newBooking.id}`
  });
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
