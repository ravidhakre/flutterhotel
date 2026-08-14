// FLUTTER HOTELS & RESORTS ADMIN DASHBOARD JAVASCRIPT

async function updateBookingStatus(bookingId, status) {
  if (!confirm(`Are you sure you want to change booking ${bookingId} status to ${status}?`)) {
    return;
  }

  try {
    const res = await fetch(`/api/admin/bookings/${bookingId}/status`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status })
    });
    const data = await res.json();

    if (data.success) {
      location.reload();
    } else {
      alert('Error updating status: ' + data.message);
    }
  } catch (err) {
    console.error(err);
    alert('Failed to update booking status.');
  }
}

async function deleteBooking(bookingId) {
  if (!confirm(`Are you sure you want to permanently delete booking ${bookingId}?`)) {
    return;
  }

  try {
    const res = await fetch(`/api/admin/bookings/${bookingId}`, {
      method: 'DELETE'
    });
    const data = await res.json();
    if (data.success) {
      location.reload();
    }
  } catch (err) {
    console.error(err);
    alert('Failed to delete booking.');
  }
}

async function deleteRoom(roomId) {
  if (!confirm('Are you sure you want to delete this room from hotel inventory?')) {
    return;
  }

  try {
    const res = await fetch(`/api/admin/rooms/${roomId}`, {
      method: 'DELETE'
    });
    const data = await res.json();
    if (data.success) {
      location.reload();
    }
  } catch (err) {
    console.error(err);
    alert('Failed to delete room.');
  }
}

// Add Room Modal Handler
document.addEventListener('DOMContentLoaded', () => {
  const addRoomForm = document.getElementById('addRoomForm');
  if (addRoomForm) {
    addRoomForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      const formData = new FormData(addRoomForm);
      const data = Object.fromEntries(formData.entries());

      try {
        const res = await fetch('/api/admin/rooms', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data)
        });
        const result = await res.json();
        if (result.success) {
          alert('Room added successfully!');
          location.reload();
        } else {
          alert('Error: ' + result.message);
        }
      } catch (err) {
        console.error(err);
        alert('Failed to add room.');
      }
    });
  }
});
