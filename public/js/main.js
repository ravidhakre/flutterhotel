document.addEventListener('DOMContentLoaded', () => {
  console.log('Flutter Hotels & Resorts App Initialized');

  // ==========================================
  // 1. HERO CAROUSEL SLIDER LOGIC
  // ==========================================
  const slides = document.querySelectorAll('.hero-slide');
  const dots = document.querySelectorAll('.slider-dots .dot');
  const prevBtn = document.getElementById('sliderPrevBtn');
  const nextBtn = document.getElementById('sliderNextBtn');
  let currentSlide = 0;
  let slideInterval = null;

  function showSlide(index) {
    if (slides.length === 0) return;
    
    if (index >= slides.length) currentSlide = 0;
    else if (index < 0) currentSlide = slides.length - 1;
    else currentSlide = index;

    slides.forEach((slide, i) => {
      slide.classList.toggle('active', i === currentSlide);
    });

    dots.forEach((dot, i) => {
      dot.classList.toggle('active', i === currentSlide);
    });
  }

  function nextSlide() {
    showSlide(currentSlide + 1);
  }

  function prevSlide() {
    showSlide(currentSlide - 1);
  }

  function startAutoSlide() {
    stopAutoSlide();
    slideInterval = setInterval(nextSlide, 5000);
  }

  function stopAutoSlide() {
    if (slideInterval) clearInterval(slideInterval);
  }

  if (slides.length > 0) {
    showSlide(0);
    startAutoSlide();

    if (nextBtn) {
      nextBtn.addEventListener('click', () => {
        nextSlide();
        startAutoSlide();
      });
    }

    if (prevBtn) {
      prevBtn.addEventListener('click', () => {
        prevSlide();
        startAutoSlide();
      });
    }

    dots.forEach((dot, i) => {
      dot.addEventListener('click', () => {
        showSlide(i);
        startAutoSlide();
      });
    });

    const heroSection = document.querySelector('.hero-slider-section');
    if (heroSection) {
      heroSection.addEventListener('mouseenter', stopAutoSlide);
      heroSection.addEventListener('mouseleave', startAutoSlide);
    }
  }

  // ==========================================
  // 2. MOBILE NAVIGATION DRAWER TOGGLE LOGIC
  // ==========================================
  const navToggleBtn = document.getElementById('mobileNavToggle');
  const navCloseBtn = document.getElementById('mobileMenuClose');
  const navLinksMenu = id('primaryNavLinks');
  const navOverlay = document.getElementById('mobileNavOverlay');

  function toggleMobileMenu() {
    if (navLinksMenu && navOverlay) {
      navLinksMenu.classList.toggle('active');
      navOverlay.classList.toggle('active');
      
      if (navToggleBtn) {
        const icon = navToggleBtn.querySelector('i');
        if (icon) {
          if (navLinksMenu.classList.contains('active')) {
            icon.className = 'fas fa-xmark';
          } else {
            icon.className = 'fas fa-bars-staggered';
          }
        }
      }
    }
  }

  function id(name) { return document.getElementById(name); }

  if (navToggleBtn) {
    navToggleBtn.addEventListener('click', toggleMobileMenu);
  }

  if (navCloseBtn) {
    navCloseBtn.addEventListener('click', toggleMobileMenu);
  }

  if (navOverlay) {
    navOverlay.addEventListener('click', toggleMobileMenu);
  }

  // Close menu when clicking links on mobile
  if (navLinksMenu) {
    const links = navLinksMenu.querySelectorAll('a');
    links.forEach(link => {
      link.addEventListener('click', (e) => {
        if (link.id === 'moreDropdownBtn' && window.innerWidth <= 992) {
          e.preventDefault();
          const container = document.getElementById('moreDropdownContainer');
          if (container) container.classList.toggle('open');
        } else if (navLinksMenu.classList.contains('active')) {
          toggleMobileMenu();
        }
      });
    });
  }

  // ==========================================
  // 3. DATEPICKER DEFAULTS
  // ==========================================
  const checkInInput = document.getElementById('checkIn');
  const checkOutInput = document.getElementById('checkOut');

  if (checkInInput && checkOutInput) {
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const formatDate = (date) => date.toISOString().split('T')[0];

    if (!checkInInput.value) checkInInput.value = formatDate(today);
    if (!checkOutInput.value) checkOutInput.value = formatDate(tomorrow);

    checkInInput.min = formatDate(today);
    checkOutInput.min = formatDate(tomorrow);
  }

  // ==========================================
  // 4. INSTANT ROOM RESERVATION API HANDLER
  // ==========================================
  const roomBookingForm = document.getElementById('roomBookingForm');
  if (roomBookingForm) {
    roomBookingForm.addEventListener('submit', async (e) => {
      e.preventDefault();

      const formData = new FormData(roomBookingForm);
      const payload = Object.fromEntries(formData.entries());

      try {
        const response = await fetch('/api/bookings', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });

        const data = await response.json();
        if (data.success) {
          window.location.href = data.redirectUrl;
        } else {
          alert('Booking error: ' + (data.message || 'Could not complete reservation.'));
        }
      } catch (err) {
        console.error('Reservation submit error:', err);
        alert('Could not submit booking request. Please call or WhatsApp our concierge.');
      }
    });
  }
});
