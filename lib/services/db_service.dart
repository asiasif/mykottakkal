import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mykottakkal/models/user_model.dart';
import 'package:mykottakkal/models/worker_model.dart';
import 'package:mykottakkal/models/shop_update_model.dart';
import 'package:mykottakkal/models/booking_model.dart';
import 'package:mykottakkal/models/shop_model.dart';
import 'package:mykottakkal/models/review_model.dart'; // Import ReviewModel
import 'package:mykottakkal/models/chat_model.dart'; // Import ChatModel
import 'package:mykottakkal/models/shop_order_model.dart'; // Import ShopOrderModel
import 'package:mykottakkal/models/dish_model.dart'; // Import DishModel
import 'package:mykottakkal/models/issue_model.dart'; // Import IssueModel
import 'package:mykottakkal/models/event_model.dart'; // Import EventModel
import 'package:mykottakkal/models/event_booking_model.dart'; // Import EventBookingModel
import 'package:mykottakkal/models/job_model.dart'; // Import JobModel
import 'package:mykottakkal/models/auto_stand_model.dart'; // Import AutoStandModel
import 'package:mykottakkal/models/ad_model.dart'; // Import AdModel
import 'package:mykottakkal/models/donor_model.dart'; // Import DonorModel
import 'package:mykottakkal/models/bus_model.dart'; // Import BusModel
import 'package:mykottakkal/models/tourism_model.dart'; // Import TourismModel
import 'package:mykottakkal/models/rental_model.dart'; // Import RentalModel
import 'package:mykottakkal/models/emergency_model.dart'; // Import EmergencyModel
import 'package:mykottakkal/models/job_application_model.dart'; // Import JobApplicationModel

class DbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Shop Order Operations ---
  Future<void> placeShopOrder(ShopOrderModel order) async {
    await _db.collection('shop_orders').doc(order.id).set(order.toMap());
  }

  Stream<List<ShopOrderModel>> getShopOrdersForUser(String userId) {
    return _db
        .collection('shop_orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
            final orders = snapshot.docs
                .map((doc) => ShopOrderModel.fromMap(doc.data()))
                .toList();
            orders.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Client-side Sort
            return orders;
        });
  }

  Stream<List<ShopOrderModel>> getShopOrdersForShop(String shopId) {
    return _db
        .collection('shop_orders')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) {
            final orders = snapshot.docs
                .map((doc) => ShopOrderModel.fromMap(doc.data()))
                .toList();
            orders.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Client-side Sort
            return orders;
        });
  }

  Future<void> updateShopOrderStatus(String orderId, String status) async {
    await _db.collection('shop_orders').doc(orderId).update({'status': status});
  }

  // Get ALL bookings (for Admin)
  Stream<List<BookingModel>> getAllBookings() {
    return _db
        .collection('bookings')
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data()))
            .toList());
  }

  // --- User Operations ---
  Future<void> saveUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Stream<UserModel?> getUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!);
    });
  }

  // Get ALL users for Admin
  Stream<List<UserModel>> getAllUsers() {
    return _db.collection('users').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList());
  }

  // Delete a user (Admin only)
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // --- Worker Operations ---

  // Save a new worker profile
  Future<void> saveWorkerProfile(WorkerModel worker) async {
    await _db.collection('workers').doc(worker.uid).set(worker.toMap());
  }

  // Get single worker profile by UID
  Stream<WorkerModel?> getWorker(String uid) {
    return _db.collection('workers').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return WorkerModel.fromMap(doc.data()!, doc.id);
    });
  }

  // Get all 'Active' and 'Verified' workers for a specific category
  Stream<List<WorkerModel>> getWorkersByCategory(String category) {
    return _db
        .collection('workers')
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'Approved') // Filter by Approved
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkerModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get ALL workers (for Admin to view list)
  Stream<List<WorkerModel>> getAllWorkers() {
    return _db.collection('workers').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => WorkerModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Get ALL pending workers (for Admin)
  Stream<List<WorkerModel>> getPendingWorkers() {
    return _db.collection('workers')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkerModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Update Worker Status (Approve/Reject)
  Future<void> updateWorkerStatus(String uid, String status) async {
    await _db.collection('workers').doc(uid).update({
      'status': status,
      'approvedDate': status == 'Approved' ? DateTime.now().toIso8601String() : null
    });
  }

  // Update Worker Location
  Future<void> updateWorkerLocation(String uid, double latitude, double longitude) async {
    await _db.collection('workers').doc(uid).update({
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  // Delete a worker (Admin only)
  Future<void> deleteWorker(String uid) async {
    await _db.collection('workers').doc(uid).delete();
  }

  // --- Merchant Operations ---

  // Post a new update
  Future<void> postShopUpdate(ShopUpdateModel update) async {
    await _db.collection('shop_updates').doc(update.id).set(update.toMap());
  }

  // Get live feed of shop updates
  Stream<List<ShopUpdateModel>> getShopUpdates() {
    return _db
        .collection('shop_updates')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ShopUpdateModel(
                  id: doc['id'],
                  shopName: doc['shopName'],
                  message: doc['message'],
                  timestamp: DateTime.fromMillisecondsSinceEpoch(doc['timestamp']),
                  isActive: doc['isActive'],
                ))
            .toList());
  }
  // --- Shop Owner Operations ---
  Future<void> createShopApplication(ShopModel shop) async {
    await _db.collection('shops').doc(shop.uid).set(shop.toMap());
  }

  Future<ShopModel?> getShopData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('shops').doc(uid).get();
      if (doc.exists) {
        return ShopModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error fetching shop data: $e");
      return null;
    }
  }

  Stream<List<ShopModel>> getPendingShops() {
    return _db.collection('shops')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ShopModel.fromMap(doc.data())).toList());
  }

  Stream<List<ShopModel>> getApprovedShops() {
    return _db.collection('shops')
        .where('status', isEqualTo: 'Approved')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ShopModel.fromMap(doc.data())).toList());
  }
  
  Stream<List<ShopModel>> getShopsByCategory(String category) {
    Query query = _db.collection('shops').where('status', isEqualTo: 'Approved');
    if (category != 'All') {
      query = query.where('shopType', isEqualTo: category);
    }
    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => ShopModel.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }

  Future<void> updateShopStatus(String uid, String status) async {
    Map<String, dynamic> data = {'status': status};
    if (status == 'Approved') {
      data['approvedDate'] = DateTime.now().millisecondsSinceEpoch;
    }
    await _db.collection('shops').doc(uid).update(data);
  }
  
  Future<void> deleteShop(String uid) async {
    await _db.collection('shops').doc(uid).delete();
  }
  
  // --- Booking Operations ---
  Future<void> createBooking(BookingModel booking) async {
    await _db.collection('bookings').doc(booking.id).set(booking.toMap());
  }

  Stream<List<BookingModel>> getBookingsForWorker(String workerId) {
    return _db
        .collection('bookings')
        .where('workerId', isEqualTo: workerId)
        .snapshots()
        .map((snapshot) {
            final bookings = snapshot.docs
                .map((doc) => BookingModel.fromMap(doc.data()))
                .toList();
            bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate)); // Client-side Sort
            return bookings;
        });
  }

  Stream<List<BookingModel>> getBookingsForUser(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
            final bookings = snapshot.docs
                .map((doc) => BookingModel.fromMap(doc.data()))
                .toList();
            bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate)); // Client-side Sort
            return bookings;
        });
  }

  // Update Booking Status
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await _db.collection('bookings').doc(bookingId).update({'status': newStatus});
  }

  // Check if worker is available on a specific date
  Future<bool> isWorkerAvailable(String workerId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final query = await _db.collection('bookings')
        .where('workerId', isEqualTo: workerId)
        .where('bookingDate', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
        .where('bookingDate', isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch)
        .where('status', whereIn: ['Pending', 'Confirmed']) // Count occupied only if active
        .get();

    return query.docs.isEmpty;
  }

  // Get list of booked dates for a worker (for Calendar)
  Future<List<DateTime>> getBookedDates(String workerId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    final query = await _db.collection('bookings')
        .where('workerId', isEqualTo: workerId)
        .where('bookingDate', isGreaterThanOrEqualTo: todayStart.millisecondsSinceEpoch)
        .where('status', whereIn: ['Pending', 'Confirmed', 'On the Way', 'Working'])
        .get();

    return query.docs
        .map((doc) => BookingModel.fromMap(doc.data()).bookingDate)
        .toList();
  }

  // Get stream of booked dates for real-time updates
  Stream<List<DateTime>> getBookedDatesStream(String workerId) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    return _db.collection('bookings')
        .where('workerId', isEqualTo: workerId)
        .where('bookingDate', isGreaterThanOrEqualTo: todayStart.millisecondsSinceEpoch)
        .where('status', whereIn: ['Pending', 'Confirmed', 'On the Way', 'Working'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data()).bookingDate)
            .toList());
  }

    // --- Review Operations ---
  Future<void> submitReview(ReviewModel review, String bookingId) async {
    // 1. Save Review
    await _db.collection('reviews').doc(review.id).set(review.toMap());

    // 2. Update Booking as 'Rated'
    await _db.collection('bookings').doc(bookingId).update({'isRated': true});

    // 3. Update Worker Rating
    final workerRef = _db.collection('workers').doc(review.workerId);
    
    await _db.runTransaction((transaction) async {
      final workerSnapshot = await transaction.get(workerRef);
      if (!workerSnapshot.exists) {
        throw Exception("Worker does not exist!");
      }

      final workerData = workerSnapshot.data()!;
      // Handle the case where fields might be missing by defaulting them
      final currentRatingCount = (workerData['ratingCount'] ?? 0) as int;
      final currentTotalRating = (workerData['totalRating'] ?? 0.0).toDouble();

      final newRatingCount = currentRatingCount + 1;
      final newTotalRating = currentTotalRating + review.rating;
      final newAverageRating = newTotalRating / newRatingCount;

      transaction.update(workerRef, {
        'ratingCount': newRatingCount,
        'totalRating': newTotalRating,
        'rating': newAverageRating,
      });
    });
  }

  // Get reviews for a worker
  Stream<List<ReviewModel>> getReviewsForWorker(String workerId) {
    return _db
        .collection('reviews')
        .where('workerId', isEqualTo: workerId)
        .snapshots()
        .map((snapshot) {
            final reviews = snapshot.docs
                .map((doc) => ReviewModel.fromMap(doc.data()))
                .toList();
            reviews.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Client-side Sort
            return reviews;
        });
  }
  // --- Chat Operations ---
  Future<void> sendMessage(String bookingId, ChatModel message) async {
    await _db
        .collection('bookings')
        .doc(bookingId)
        .collection('messages')
        .add(message.toMap());
  }

  Stream<List<ChatModel>> getMessages(String bookingId) {
    return _db
        .collection('bookings')
        .doc(bookingId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromMap(doc.data()))
            .toList());
  }

  // --- Dish Operations (Shop Owner) ---
  Future<void> addDish(DishModel dish) async {
    await _db.collection('dishes').doc(dish.id).set(dish.toMap());
  }

  Future<void> updateDish(DishModel dish) async {
    await _db.collection('dishes').doc(dish.id).update(dish.toMap());
  }

  Future<void> deleteDish(String dishId) async {
    await _db.collection('dishes').doc(dishId).delete();
  }

  Stream<List<DishModel>> getDishesByShop(String shopId) {
    return _db
        .collection('dishes')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map((snapshot) {
            final dishes = snapshot.docs
                .map((doc) => DishModel.fromMap(doc.data(), doc.id))
                .toList();
            return dishes;
        });
  }

  // --- City Issue Reporting (Civic) ---

  // Report a new issue
  Future<void> reportIssue(IssueModel issue) async {
    await _db.collection('issues').doc(issue.id).set(issue.toMap());
  }

  // Get User's reported issues
  Stream<List<IssueModel>> getUserIssues(String userId) {
    return _db
        .collection('issues')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
            final issues = snapshot.docs
                .map((doc) => IssueModel.fromMap(doc.data()))
                .toList();
            issues.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Client-side Sort
            return issues;
        });
  }

  // Get ALL issues (for Admin)
  Stream<List<IssueModel>> getAllIssues() {
    return _db
        .collection('issues')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IssueModel.fromMap(doc.data()))
            .toList());
  }

  // Update Status & Award Points
  Future<void> updateIssueStatus(String issueId, String newStatus, String userId) async {
    // 1. Update Status
    await _db.collection('issues').doc(issueId).update({'status': newStatus});

    // 2. Award Points if Resolved
    if (newStatus == 'Resolved') {
      await _db.collection('users').doc(userId).update({
        'points': FieldValue.increment(10),
      });
    }
  }

  // Deduct Points (for Shop Discount)
  Future<void> deductPoints(String userId, int points) async {
    await _db.collection('users').doc(userId).update({
      'points': FieldValue.increment(-points),
    });
  }

  // --- Local Events & News ---

  Future<void> addEvent(EventModel event) async {
    await _db.collection('events').doc(event.id).set(event.toMap());
  }

  Future<void> deleteEvent(String id) async {
    await _db.collection('events').doc(id).delete();
  }

  Stream<List<EventModel>> getEvents() {
    return _db
        .collection('events')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.data()))
            .toList());
  }

  // Event Bookings

  Future<void> bookEvent(EventBookingModel booking) async {
    // Optional: Check if already booked
    final existing = await _db.collection('event_bookings')
        .where('eventId', isEqualTo: booking.eventId)
        .where('userId', isEqualTo: booking.userId)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception("You have already booked this event.");
    }

    await _db.collection('event_bookings').doc(booking.id).set(booking.toMap());
  }

  Stream<List<EventBookingModel>> getEventBookings(String eventId) {
    return _db
        .collection('event_bookings')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
            final bookings = snapshot.docs.map((doc) => EventBookingModel.fromMap(doc.data())).toList();
            bookings.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Client-side Sort
            return bookings;
        });
  }

  // Jobs

  Future<void> postJob(JobModel job) async {
    await _db.collection('jobs').doc(job.id).set(job.toMap());
  }

  Future<void> deleteJob(String id) async {
    await _db.collection('jobs').doc(id).delete();
  }

  Stream<List<JobModel>> getJobs() {
    return _db.collection('jobs')
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => JobModel.fromMap(doc.data())).toList());
  }

  // Auto Stands

  Future<void> addAutoStand(AutoStandModel stand) async {
    await _db.collection('auto_stands').doc(stand.id).set(stand.toMap());
  }

  Future<void> deleteAutoStand(String id) async {
    await _db.collection('auto_stands').doc(id).delete();
  }

  Stream<List<AutoStandModel>> getAutoStands() {
    return _db.collection('auto_stands')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AutoStandModel.fromMap(doc.data())).toList());
  }

  // Classifieds (Local CLX)

  Future<void> postAd(AdModel ad) async {
    await _db.collection('classifieds').doc(ad.id).set(ad.toMap());
  }

  Future<void> deleteAd(String id) async {
    await _db.collection('classifieds').doc(id).delete();
  }

  Stream<List<AdModel>> getAds() {
    return _db.collection('classifieds')
        .orderBy('postedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AdModel.fromMap(doc.data())).toList());
  }

  // Blood Network

  Future<void> registerDonor(DonorModel donor) async {
    await _db.collection('donors').doc(donor.uid).set(donor.toMap());
  }

  Stream<List<DonorModel>> getDonors(String? bloodGroup) {
    Query query = _db.collection('donors').where('isAvailable', isEqualTo: true);
    
    if (bloodGroup != null && bloodGroup != 'All') {
      query = query.where('bloodGroup', isEqualTo: bloodGroup);
    }

    return query.snapshots().map((snapshot) => 
        snapshot.docs.map((doc) => DonorModel.fromMap(doc.data() as Map<String, dynamic>)).toList()
    );
  }

  Future<DonorModel?> getCurrentDonorProfile(String uid) async {
    final doc = await _db.collection('donors').doc(uid).get();
    if (doc.exists) {
        return DonorModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Bus Timings

  Future<void> addBusTiming(BusModel bus) async {
    await _db.collection('bus_timings').doc(bus.id).set(bus.toMap());
  }

  Future<void> deleteBusTiming(String id) async {
    await _db.collection('bus_timings').doc(id).delete();
  }

  Stream<List<BusModel>> getBusTimings(String? route) {
    Query query = _db.collection('bus_timings');
    
    if (route != null && route != 'All') {
      query = query.where('route', isEqualTo: route);
    }

    return query.snapshots().map((snapshot) {
        final buses = snapshot.docs.map((doc) => BusModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
        buses.sort((a, b) => a.time.compareTo(b.time)); // Client-side Sort
        return buses;
    });
  }

  // Tourism

  Future<void> addPlace(TourismModel place) async {
    await _db.collection('tourism').doc(place.id).set(place.toMap());
  }

  Future<void> deletePlace(String id) async {
    await _db.collection('tourism').doc(id).delete();
  }

  Stream<List<TourismModel>> getPlaces() {
    return _db.collection('tourism')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TourismModel.fromMap(doc.data())).toList());
  }

  // Rentals

  Future<void> addRental(RentalModel rental) async {
    await _db.collection('rentals').doc(rental.id).set(rental.toMap());
  }

  Future<void> deleteRental(String id) async {
    await _db.collection('rentals').doc(id).delete();
  }

  Stream<List<RentalModel>> getRentals(String? category) {
    Query query = _db.collection('rentals');
    
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
        final rentals = snapshot.docs.map((doc) => RentalModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
        rentals.sort((a, b) => b.date.compareTo(a.date)); // Client-side Sort
        return rentals;
    });
  }

  // Emergency Helpline

  Future<void> addEmergencyContact(EmergencyModel contact) async {
    await _db.collection('emergency').doc(contact.id).set(contact.toMap());
  }

  Future<void> deleteEmergencyContact(String id) async {
    await _db.collection('emergency').doc(id).delete();
  }

  Stream<List<EmergencyModel>> getEmergencyContacts() {
    return _db.collection('emergency')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => EmergencyModel.fromMap(doc.data())).toList());
  }

  // --- Job Applications ---

  Future<void> applyForJob(JobApplicationModel application) async {
    // Check if already applied
    final existing = await _db.collection('job_applications')
        .where('jobId', isEqualTo: application.jobId)
        .where('applicantId', isEqualTo: application.applicantId)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception("You have already applied for this job.");
    }

    await _db.collection('job_applications').doc(application.id).set(application.toMap());
  }

  Stream<List<JobApplicationModel>> getJobApplications(String jobId) {
    return _db.collection('job_applications')
        .where('jobId', isEqualTo: jobId)
        .snapshots()
        .map((snapshot) {
            final apps = snapshot.docs.map((doc) => JobApplicationModel.fromMap(doc.data())).toList();
            apps.sort((a, b) => b.appliedDate.compareTo(a.appliedDate)); // Client-side Sort
            return apps;
        });
  }
}

