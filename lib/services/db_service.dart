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
import 'package:mykottakkal/models/herb_model.dart';
import 'package:mykottakkal/models/wellness_center_model.dart';
import 'package:mykottakkal/models/wellness_booking_model.dart';
import 'package:mykottakkal/models/football_match_model.dart';
import 'package:mykottakkal/models/bulletin_notice_model.dart';

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

  // --- Ayurvedic Wellness Hub ---

  Stream<List<HerbModel>> getHerbs() {
    return _db.collection('herbs').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        _seedHerbs();
        return [];
      }
      return snapshot.docs.map((doc) => HerbModel.fromMap(doc.data())).toList();
    });
  }

  Future<void> _seedHerbs() async {
    final herbs = [
      HerbModel(
        id: 'herb_1',
        name: 'Tulsi',
        localName: 'വിശുദ്ധ തുളസി (Krishna Tulsi)',
        scientificName: 'Ocimum tenuiflorum',
        benefits: '• Boosts respiratory health and relieves cough.\n• Helps reduce stress and lower blood pressure.\n• High in antioxidants, supporting overall immunity.',
        howToUse: 'Boil fresh Tulsi leaves with black pepper and ginger in water to make a healing herbal tea. Drink twice daily.',
        imageUrl: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&q=80&w=400',
      ),
      HerbModel(
        id: 'herb_2',
        name: 'Neem',
        localName: 'ആര്യവേപ്പ് (Aryaveppu)',
        scientificName: 'Azadirachta indica',
        benefits: '• Highly effective blood purifier and anti-inflammatory agent.\n• Cures skin conditions like acne, eczema, and rashes.\n• Supports oral health and hygiene.',
        howToUse: 'Grind neem leaves into a paste and apply directly to skin issues, or consume 1-2 fresh leaves on an empty stomach for detoxification.',
        imageUrl: 'https://images.unsplash.com/photo-1600411832986-5a44d18c5a14?auto=format&fit=crop&q=80&w=400',
      ),
      HerbModel(
        id: 'herb_3',
        name: 'Ashwagandha',
        localName: 'അമുക്കുരം (Amukkuram)',
        scientificName: 'Withania somnifera',
        benefits: '• Promotes strength, vitality, and muscle recovery.\n• Dramatically lowers cortisol (stress hormone) levels.\n• Enhances sleep quality and fights fatigue.',
        howToUse: 'Mix 1/2 teaspoon of Ashwagandha powder in warm milk or water before bedtime.',
        imageUrl: 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?auto=format&fit=crop&q=80&w=400',
      ),
      HerbModel(
        id: 'herb_4',
        name: 'Turmeric',
        localName: 'മഞ്ഞൾ (Manjal)',
        scientificName: 'Curcuma longa',
        benefits: '• Strong natural painkiller and anti-septic.\n• Supports healthy joint function and reduces swelling.\n• Enhances skin complexion and digestive power.',
        howToUse: 'Consume daily with food, or mix with milk and black pepper to make anti-inflammatory Golden Milk.',
        imageUrl: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&q=80&w=400',
      ),
    ];
    for (var herb in herbs) {
      await _db.collection('herbs').doc(herb.id).set(herb.toMap());
    }
  }

  Stream<List<WellnessCenterModel>> getWellnessCenters() {
    return _db.collection('wellness_centers').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        _seedWellnessCenters();
        return [];
      }
      return snapshot.docs.map((doc) => WellnessCenterModel.fromMap(doc.data())).toList();
    });
  }

  Future<void> _seedWellnessCenters() async {
    final centers = [
      WellnessCenterModel(
        id: 'center_1',
        name: 'Kottakkal Arya Vaidya Sala',
        imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&q=80&w=600',
        address: 'Kottakkal Junction, Malappuram, Kerala 676503',
        phone: '+91 483 280 8000',
        description: 'The historic and premier institution pioneering authentic Ayurvedic treatments, manufacturing medicines, and offering specialized therapies for over a century.',
        rating: 4.8,
        googleMapLink: 'https://maps.google.com/?q=Arya+Vaidya+Sala+Kottakkal',
      ),
      WellnessCenterModel(
        id: 'center_2',
        name: 'Ayurvihar Panchakarma Center',
        imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&q=80&w=600',
        address: 'Changuvetty, Kottakkal, Kerala 676501',
        phone: '+91 483 274 3456',
        description: 'Specializes in intensive detoxification Panchakarma treatments, rejuvenation massages (Abhyangam), and customized herbal steam baths managed by certified Vaidyas.',
        rating: 4.6,
        googleMapLink: 'https://maps.google.com/?q=Changuvetty+Kottakkal',
      ),
      WellnessCenterModel(
        id: 'center_3',
        name: 'Kailas Ayurvedic Clinic',
        imageUrl: 'https://images.unsplash.com/photo-1627672360099-083a88b38a85?auto=format&fit=crop&q=80&w=600',
        address: 'Puttur Road, Kottakkal, Kerala 676503',
        phone: '+91 94471 23456',
        description: 'A quiet, premium clinic focusing on stress management, chronic pain relief, spine care, and lifestyle coaching using classical Ayurvedic formulations.',
        rating: 4.7,
        googleMapLink: 'https://maps.google.com/?q=Kottakkal',
      ),
    ];
    for (var center in centers) {
      await _db.collection('wellness_centers').doc(center.id).set(center.toMap());
    }
  }

  Future<void> bookWellnessCenter(WellnessBookingModel booking) async {
    await _db.collection('wellness_bookings').doc(booking.id).set(booking.toMap());
  }

  Stream<List<WellnessBookingModel>> getWellnessBookingsForUser(String userId) {
    return _db
        .collection('wellness_bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) => WellnessBookingModel.fromMap(doc.data()))
              .toList();
          bookings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return bookings;
        });
  }

  Future<void> cancelWellnessBooking(String bookingId) async {
    await _db.collection('wellness_bookings').doc(bookingId).update({'status': 'Cancelled'});
  }

  // --- Malappuram Sevens Football & Bulletin Notices ---

  Stream<List<FootballMatchModel>> getFootballMatches() {
    return _db.collection('football_matches').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        _seedFootballMatches();
        return [];
      }
      final matches = snapshot.docs.map((doc) => FootballMatchModel.fromMap(doc.data())).toList();
      matches.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return matches;
    });
  }

  Future<void> _seedFootballMatches() async {
    final matches = [
      FootballMatchModel(
        id: 'match_1',
        teamA: 'Usha FC Thrissur',
        teamB: 'FIFA Manjeri',
        scoreA: 2,
        scoreB: 3,
        status: 'Live',
        matchTime: '8:00 PM',
        matchDate: 'Tonight',
        venue: 'Kottakkal Municipal Stadium',
        tournamentName: 'All India Sevens Kottakkal',
        timestamp: DateTime.now(),
        minute: "55'",
      ),
      FootballMatchModel(
        id: 'match_2',
        teamA: 'Sabas Calicut',
        teamB: 'Linsha Medicals Mannarkkad',
        scoreA: 1,
        scoreB: 1,
        status: 'Live',
        matchTime: '9:30 PM',
        matchDate: 'Tonight',
        venue: 'Changuvetty Grounds',
        tournamentName: 'Malabar Sevens Cup',
        timestamp: DateTime.now().subtract(Duration(minutes: 30)),
        minute: "12'",
      ),
      FootballMatchModel(
        id: 'match_3',
        teamA: 'Royal Travels Kozhikode',
        teamB: 'Gains Kovoor',
        scoreA: 0,
        scoreB: 2,
        status: 'Completed',
        matchTime: '8:00 PM',
        matchDate: 'Yesterday',
        venue: 'Kottakkal Municipal Stadium',
        tournamentName: 'All India Sevens Kottakkal',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
        minute: 'FT',
      ),
      FootballMatchModel(
        id: 'match_4',
        teamA: 'Black & White Kozhikode',
        teamB: 'Mediguard Kondotty',
        scoreA: 0,
        scoreB: 0,
        status: 'Upcoming',
        matchTime: '8:00 PM',
        matchDate: 'Jul 10',
        venue: 'Kottakkal Municipal Stadium',
        tournamentName: 'All India Sevens Kottakkal',
        timestamp: DateTime.now().add(Duration(days: 3)),
        minute: '',
      ),
    ];
    for (var match in matches) {
      await _db.collection('football_matches').doc(match.id).set(match.toMap());
    }
  }

  Future<void> postBulletinNotice(BulletinNoticeModel notice) async {
    await _db.collection('bulletin_notices').doc(notice.id).set(notice.toMap());
  }

  Stream<List<BulletinNoticeModel>> getBulletinNotices() {
    return _db.collection('bulletin_notices').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        _seedBulletinNotices();
        return [];
      }
      final notices = snapshot.docs.map((doc) => BulletinNoticeModel.fromMap(doc.data())).toList();
      notices.sort((a, b) => b.postedDate.compareTo(a.postedDate));
      return notices;
    });
  }

  Future<void> _seedBulletinNotices() async {
    final notices = [
      BulletinNoticeModel(
        id: 'notice_1',
        title: 'Water Supply Disruption',
        description: 'KWA drinking water supply will be partially disrupted tomorrow (July 7) in Changuvetty and Kottakkal Junction area due to pipe maintenance work.',
        postedBy: 'Municipality Water Dept',
        postedDate: DateTime.now().subtract(Duration(hours: 3)),
        category: 'Water/Power',
      ),
      BulletinNoticeModel(
        id: 'notice_2',
        title: 'Traffic Diversion for Temple Festival',
        description: 'Expect heavy traffic near Venkata Thevar Temple on Friday evening. Heavy vehicles are advised to take the bypass route via Puttur road.',
        postedBy: 'Traffic Police Kottakkal',
        postedDate: DateTime.now().subtract(Duration(hours: 6)),
        category: 'Traffic',
      ),
      BulletinNoticeModel(
        id: 'notice_3',
        title: 'Monsoon Dengue Prevention Camp',
        description: 'Free medical camp and dry-day campaign this Sunday at Panchayat Community Hall. Ayurvedic immunity boosters will be distributed.',
        postedBy: 'Health Center Kottakkal',
        postedDate: DateTime.now().subtract(Duration(days: 1)),
        category: 'Health Alert',
      ),
    ];
    for (var notice in notices) {
      await _db.collection('bulletin_notices').doc(notice.id).set(notice.toMap());
    }
  }
}

