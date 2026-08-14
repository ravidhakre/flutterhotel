const express = require('express');
const path = require('path');
const fs = require('fs');
const session = require('express-session');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));
app.use(session({
  secret: 'hotux_luxury_secret_key_2026',
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

// Homepage
app.get('/', (req, res) => {
  const rooms = readData('rooms.json');
  const reviews = readData('reviews.json');
  const featuredRooms = rooms.filter(r => r.featured);
  res.render('index', {
    title: 'Hotux | Luxury Hotel & Resort',
    rooms: rooms,
    featuredRooms: featuredRooms,
    reviews: reviews
  });
});

// Rooms Catalog
app.get('/rooms', (req, res) => {
  let rooms = readData('rooms.json');
  const { category, minPrice, maxPrice, guests } = req.query;

  if (category && category !== 'All') {
    rooms = rooms.filter(r => r.category.toLowerCase() === category.toLowerCase());
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
    title: 'Explore Rooms | Hotux Hotel',
    rooms: rooms,
    query: req.query
  });
});

// Single Room Detail Page
app.get('/rooms/:id', (req, res) => {
  const rooms = readData('rooms.json');
  const room = rooms.find(r => r.id === req.params.id);
  if (!room) {
    return res.status(404).render('404', { title: 'Room Not Found' });
  }
  const relatedRooms = rooms.filter(r => r.id !== room.id).slice(0, 3);
  res.render('room-detail', {
    title: `${room.name} | Hotux Hotel`,
    room: room,
    relatedRooms: relatedRooms
  });
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
    title: 'Booking Confirmed | Hotux Hotel',
    booking: booking,
    room: room
  });
});

// Contact Page
app.get('/contact', (req, res) => {
  res.render('contact', {
    title: 'Contact Us | Hotux Hotel',
    success: req.query.success || null
  });
});

// Contact Form Handler
app.post('/contact', (req, res) => {
  const { name, email, phone, subject, message } = req.body;
  if (!name || !email || !message) {
    return res.render('contact', {
      title: 'Contact Us | Hotux Hotel',
      error: 'Please fill in all required fields.'
    });
  }

  const inquiries = readData('inquiries.json');
  const newInquiry = {
    id: 'INQ-' + Math.floor(100 + Math.random() * 900),
    name,
    email,
    phone: phone || '',
    subject: subject || 'General Inquiry',
    message,
    status: 'Unread',
    date: new Date().toISOString()
  };

  inquiries.unshift(newInquiry);
  saveData('inquiries.json', inquiries);

  res.redirect('/contact?success=Thank+you!+Your+message+has+been+received.+We+will+get+back+to+you+shortly.');
});

// Login Page
app.get('/login', (req, res) => {
  res.render('login', {
    title: 'Login & Register | Hotux Hotel',
    error: req.query.error || null,
    message: req.query.message || null
  });
});

// Login POST Handler
app.post('/login', (req, res) => {
  const { username, password } = req.body;

  // Admin authentication (Default: admin / admin123)
  if ((username === 'admin' || username === 'admin@hotux.com') && password === 'admin123') {
    req.session.user = {
      id: 'admin-1',
      name: 'Manager Admin',
      username: 'admin',
      isAdmin: true
    };
    return res.redirect('/admin');
  }

  // Demo customer user
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
    title: 'Login & Register | Hotux Hotel',
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
    availableRooms = availableRooms.filter(r => r.category.toLowerCase() === roomType.toLowerCase());
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
    id: 'HTX-' + Math.floor(1000 + Math.random() * 9000),
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
    paymentMethod: paymentMethod || 'Pay at Hotel'
  };

  bookings.unshift(newBooking);
  saveData('bookings.json', bookings);

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
    title: 'Admin Dashboard | Hotux Hotel',
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
    title: 'Manage Bookings | Hotux Admin',
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
    title: 'Manage Rooms | Hotux Admin',
    rooms: rooms
  });
});

// Add Room API
app.post('/api/admin/rooms', requireAdmin, (req, res) => {
  const { name, category, price, bed, capacity, size, view, image, description, featured } = req.body;
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
    size: size || '45 sq.m',
    wifi: true,
    breakfast: true,
    view: view || 'Garden View',
    image: image || '/images/room-1.jpg',
    featured: featured === 'true' || featured === true,
    description: description || 'Luxurious accommodations with premium amenities.',
    amenities: ["Free High-speed Wi-Fi", "Air Conditioning", "Flat Screen TV", "Mini Bar", "24/7 Room Service"]
  };

  rooms.push(newRoom);
  saveData('rooms.json', rooms);
  return res.json({ success: true, message: 'Room added successfully!', room: newRoom });
});

// Update Room API
app.put('/api/admin/rooms/:id', requireAdmin, (req, res) => {
  const rooms = readData('rooms.json');
  const index = rooms.findIndex(r => r.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Room not found.' });
  }

  const updatedRoom = {
    ...rooms[index],
    ...req.body,
    price: parseFloat(req.body.price || rooms[index].price),
    capacity: parseInt(req.body.capacity || rooms[index].capacity)
  };

  rooms[index] = updatedRoom;
  saveData('rooms.json', rooms);
  return res.json({ success: true, message: 'Room updated successfully!' });
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
    title: 'Customer Inquiries | Hotux Admin',
    inquiries: inquiries
  });
});

// Update Inquiry Status API
app.patch('/api/admin/inquiries/:id/status', requireAdmin, (req, res) => {
  const { status } = req.body;
  const inquiries = readData('inquiries.json');
  const inquiry = inquiries.find(i => i.id === req.params.id);
  if (inquiry) {
    inquiry.status = status;
    saveData('inquiries.json', inquiries);
    return res.json({ success: true });
  }
  return res.status(404).json({ success: false });
});

// 404 Page Route
app.use((req, res) => {
  res.status(404).render('404', { title: 'Page Not Found | Hotux Hotel' });
});

// Start Server
app.listen(PORT, () => {
  console.log(`================================================`);
  console.log(`  HOTUX LUXURY HOTEL SERVER IS RUNNING ONLINE!  `);
  console.log(`  Public Web:  http://localhost:${PORT}          `);
  console.log(`  Admin Panel: http://localhost:${PORT}/admin    `);
  console.log(`  Admin Creds: Username: admin / Password: admin123`);
  console.log(`================================================`);
});
