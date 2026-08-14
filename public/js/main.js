// HOTUX LUXURY HOTEL CLIENT-SIDE JAVASCRIPT

document.addEventListener('DOMContentLoaded', () => {

  // Auto-set default check-in and check-out dates if present
  const checkInInput = document.getElementById('checkIn');
  const checkOutInput = document.getElementById('checkOut');

  if (checkInInput && checkOutInput) {
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 2);

    if (!checkInInput.value) {
      checkInInput.value = today.toISOString().split('T')[0];
    }
    if (!checkOutInput.value) {
      checkOutInput.value = tomorrow.toISOString().split('T')[0];
    }
  }

  // Handle Instant Booking Form Submission
  const bookingForm = document.getElementById('roomBookingForm');
  if (bookingForm) {
    bookingForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      
      const submitBtn = bookingForm.querySelector('button[type="submit"]');
      const originalText = submitBtn.innerHTML;
      submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
      submitBtn.disabled = true;

      const formData = new FormData(bookingForm);
      const data = Object.fromEntries(formData.entries());

      try {
        const response = await fetch('/api/bookings', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data)
        });

        const result = await response.json();
        if (result.success) {
          window.location.href = result.redirectUrl;
        } else {
          alert('Booking Error: ' + result.message);
          submitBtn.innerHTML = originalText;
          submitBtn.disabled = false;
        }
      } catch (err) {
        console.error('Booking Submission Error:', err);
        alert('An error occurred while placing your booking. Please try again.');
        submitBtn.innerHTML = originalText;
        submitBtn.disabled = false;
      }
    });
  }

});
