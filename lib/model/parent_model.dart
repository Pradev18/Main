class parentmodel {
  int? errorCode;
  String? errorMsg;
  int? successCode;
  Version? version;
  ParentDetails? parentDetails;
  List<ChildDetails>? childDetails;
  List<BannerList>? bannerList;

  parentmodel(
      {this.errorCode,
        this.errorMsg,
        this.successCode,
        this.version,
        this.parentDetails,
        this.childDetails,
        this.bannerList});

  parentmodel.fromJson(Map<String, dynamic> json) {
    errorCode = json['error_code'];
    errorMsg = json['error_msg'];
    successCode = json['success_code'];
    version =
    json['version'] != null ? new Version.fromJson(json['version']) : null;
    parentDetails = json['parent_details'] != null
        ? new ParentDetails.fromJson(json['parent_details'])
        : null;
    if (json['child_details'] != null) {
      childDetails = <ChildDetails>[];
      json['child_details'].forEach((v) {
        childDetails!.add(new ChildDetails.fromJson(v));
      });
    }
    if (json['banner_list'] != null) {
      bannerList = <BannerList>[];
      json['banner_list'].forEach((v) {
        bannerList!.add(new BannerList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error_code'] = this.errorCode;
    data['error_msg'] = this.errorMsg;
    data['success_code'] = this.successCode;
    if (this.version != null) {
      data['version'] = this.version!.toJson();
    }
    if (this.parentDetails != null) {
      data['parent_details'] = this.parentDetails!.toJson();
    }
    if (this.childDetails != null) {
      data['child_details'] =
          this.childDetails!.map((v) => v.toJson()).toList();
    }
    if (this.bannerList != null) {
      data['banner_list'] = this.bannerList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Version {
  String? iOS;
  String? aNDROID;

  Version({this.iOS, this.aNDROID});

  Version.fromJson(Map<String, dynamic> json) {
    iOS = json['IOS'];
    aNDROID = json['ANDROID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IOS'] = this.iOS;
    data['ANDROID'] = this.aNDROID;
    return data;
  }
}

class ParentDetails {
  String? parentId;
  String? parentName;
  String? parentEmail;
  String? parentPhone;
  String? parentAddress;
  String? parentDob;
  String? parentPhoto;

  ParentDetails(
      {this.parentId,
        this.parentName,
        this.parentEmail,
        this.parentPhone,
        this.parentAddress,
        this.parentDob,
        this.parentPhoto});

  ParentDetails.fromJson(Map<String, dynamic> json) {
    parentId = json['parent_id'];
    parentName = json['parent_name'];
    parentEmail = json['parent_email'];
    parentPhone = json['parent_phone'];
    parentAddress = json['parent_address'];
    parentDob = json['parent_dob'];
    parentPhoto = json['parent_photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['parent_id'] = this.parentId;
    data['parent_name'] = this.parentName;
    data['parent_email'] = this.parentEmail;
    data['parent_phone'] = this.parentPhone;
    data['parent_address'] = this.parentAddress;
    data['parent_dob'] = this.parentDob;
    data['parent_photo'] = this.parentPhoto;
    return data;
  }
}

class ChildDetails {
  String? childId;
  String? parentId;
  String? childName;
  String? childDob;
  String? childGender;
  String? childBloodGroupId;
  String? schoolId;
  String? childStandard;
  String? childDivision;
  String? childPickupAddress;
  String? childPickupLatitude;
  String? childPickupLongitude;
  String? actualPickupLatLongAdded;
  String? childDropAddress;
  String? childDropLatitude;
  String? childDropLongitude;
  String? actualDropLatLongAdded;
  String? contractExpiryDate;
  String? childPhoto;
  String? pickupPersonName;
  String? pickupPersonPhone;
  String? emergencyContactNo;
  String? fatherMobileNo;
  String? motherMobileNo;
  String? pickupRouteId;
  String? dropRouteId;
  String? pickupStopId;
  String? dropStopId;
  String? childStatus;
  String? dateCreated;
  String? lastModified;
  String? schoolName;
  String? shotEta;
  String? schoolAddress;
  String? pickupRouteName;
  String? pickupRouteStartTime;
  String? pickupRouteEndTime;
  String? pickupRouteTrackingType;
  String? dropRouteName;
  String? dropRouteStartTime;
  String? dropRouteEndTime;
  String? dropRouteTrackingType;
  String? pickupAttendantName;
  String? pickupAttendantPhoto;
  String? pickupAttendantPhone1;
  String? pickupAttendantPhone2;
  String? dropAttendantName;
  String? dropAttendantPhoto;
  String? dropAttendantPhone1;
  String? dropAttendantPhone2;
  String? pickupDriverName;
  String? pickupDriverPhoto;
  String? pickupDriverPhone1;
  String? pickupDriverPhone2;
  String? dropDriverName;
  String? dropDriverPhoto;
  String? dropDriverPhone1;
  String? dropDriverPhone2;
  String? childPhotoUrl;
  String? pickupVehicleNumber;
  String? pickupVehicleId;
  String? dropVehicleNumber;
  String? dropVehicleId;
  String? trackLiveUrl;
  String? galaPickupUrl;
  String? galaDropUrl;
  String? showPaymentButton;
  String? childPaymentId;
  String? paymentamt;

  ChildDetails(
      {this.childId,
        this.parentId,
        this.childName,
        this.childDob,
        this.childGender,
        this.childBloodGroupId,
        this.schoolId,
        this.childStandard,
        this.childDivision,
        this.childPickupAddress,
        this.childPickupLatitude,
        this.childPickupLongitude,
        this.actualPickupLatLongAdded,
        this.childDropAddress,
        this.childDropLatitude,
        this.childDropLongitude,
        this.actualDropLatLongAdded,
        this.contractExpiryDate,
        this.childPhoto,
        this.pickupPersonName,
        this.pickupPersonPhone,
        this.emergencyContactNo,
        this.fatherMobileNo,
        this.motherMobileNo,
        this.pickupRouteId,
        this.dropRouteId,
        this.pickupStopId,
        this.dropStopId,
        this.childStatus,
        this.dateCreated,
        this.lastModified,
        this.schoolName,
        this.shotEta,
        this.schoolAddress,
        this.pickupRouteName,
        this.pickupRouteStartTime,
        this.pickupRouteEndTime,
        this.pickupRouteTrackingType,
        this.dropRouteName,
        this.dropRouteStartTime,
        this.dropRouteEndTime,
        this.dropRouteTrackingType,
        this.pickupAttendantName,
        this.pickupAttendantPhoto,
        this.pickupAttendantPhone1,
        this.pickupAttendantPhone2,
        this.dropAttendantName,
        this.dropAttendantPhoto,
        this.dropAttendantPhone1,
        this.dropAttendantPhone2,
        this.pickupDriverName,
        this.pickupDriverPhoto,
        this.pickupDriverPhone1,
        this.pickupDriverPhone2,
        this.dropDriverName,
        this.dropDriverPhoto,
        this.dropDriverPhone1,
        this.dropDriverPhone2,
        this.childPhotoUrl,
        this.pickupVehicleNumber,
        this.pickupVehicleId,
        this.dropVehicleNumber,
        this.dropVehicleId,
        this.trackLiveUrl,
        this.galaPickupUrl,
        this.galaDropUrl,
        this.showPaymentButton,
        this.childPaymentId,
        this.paymentamt});

  ChildDetails.fromJson(Map<String, dynamic> json) {
    childId = json['child_id'];
    parentId = json['parent_id'];
    childName = json['child_name'];
    childDob = json['child_dob'];
    childGender = json['child_gender'];
    childBloodGroupId = json['child_blood_group_id'];
    schoolId = json['school_id'];
    childStandard = json['child_standard'];
    childDivision = json['child_division'];
    childPickupAddress = json['child_pickup_address'];
    childPickupLatitude = json['child_pickup_latitude'];
    childPickupLongitude = json['child_pickup_longitude'];
    actualPickupLatLongAdded = json['actual_pickup_lat_long_added'];
    childDropAddress = json['child_drop_address'];
    childDropLatitude = json['child_drop_latitude'];
    childDropLongitude = json['child_drop_longitude'];
    actualDropLatLongAdded = json['actual_drop_lat_long_added'];
    contractExpiryDate = json['contract_expiry_date'];
    childPhoto = json['child_photo'];
    pickupPersonName = json['pickup_person_name'];
    pickupPersonPhone = json['pickup_person_phone'];
    emergencyContactNo = json['emergency_contact_no'];
    fatherMobileNo = json['father_mobile_no'];
    motherMobileNo = json['mother_mobile_no'];
    pickupRouteId = json['pickup_route_id'];
    dropRouteId = json['drop_route_id'];
    pickupStopId = json['pickup_stop_id'];
    dropStopId = json['drop_stop_id'];
    childStatus = json['child_status'];
    dateCreated = json['date_created'];
    lastModified = json['last_modified'];
    schoolName = json['school_name'];
    shotEta = json['show_eta'];
    schoolAddress = json['school_address'];
    pickupRouteName = json['pickup_route_name'];
    pickupRouteStartTime = (json['pickup_route_start_time'] ?? '').isEmpty
        ? '00:00:00'
        : json['pickup_route_start_time'];
    pickupRouteEndTime = (json['pickup_route_end_time']).isEmpty
        ? '00:00:00'
        : json['pickup_route_end_time'];
    pickupRouteTrackingType = json['pickup_route_tracking_type'];
    dropRouteName = json['drop_route_name'];
    dropRouteStartTime = (json['drop_route_start_time']?? '').isEmpty
        ? '00:00:00'
        : json['drop_route_start_time'];
    dropRouteEndTime = (json['drop_route_end_time']).isEmpty
        ? '00:00:00'
        : json['drop_route_end_time'];
    dropRouteTrackingType = json['drop_route_tracking_type'];
    pickupAttendantName = json['pickup_attendant_name'];
    pickupAttendantPhoto = json['pickup_attendant_photo'];
    pickupAttendantPhone1 = json['pickup_attendant_phone1'];
    pickupAttendantPhone2 = json['pickup_attendant_phone2'];
    dropAttendantName = json['drop_attendant_name'];
    dropAttendantPhoto = json['drop_attendant_photo'];
    dropAttendantPhone1 = json['drop_attendant_phone1'];
    dropAttendantPhone2 = json['drop_attendant_phone2'];
    pickupDriverName = json['pickup_driver_name'];
    pickupDriverPhoto = json['pickup_driver_photo'];
    pickupDriverPhone1 = json['pickup_driver_phone1'];
    pickupDriverPhone2 = json['pickup_driver_phone2'];
    dropDriverName = json['drop_driver_name'];
    dropDriverPhoto = json['drop_driver_photo'];
    dropDriverPhone1 = json['drop_driver_phone1'];
    dropDriverPhone2 = json['drop_driver_phone2'];
    childPhotoUrl = json['child_photo_url'];
    pickupVehicleNumber = json['pickup_vehicle_number'];
    pickupVehicleId = json['pickup_vehicle_id'];
    dropVehicleNumber = json['drop_vehicle_number'];
    dropVehicleId = json['drop_vehicle_id'];
    trackLiveUrl = json['track_live_url'];
    galaPickupUrl = json['gala_pickup_url'];
    galaDropUrl = json['gala_drop_url'];
    showPaymentButton = json['show_payment_button'];
    childPaymentId = json['child_payment_id'];
    paymentamt = json['payment_amt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['child_id'] = this.childId;
    data['parent_id'] = this.parentId;
    data['child_name'] = this.childName;
    data['child_dob'] = this.childDob;
    data['child_gender'] = this.childGender;
    data['child_blood_group_id'] = this.childBloodGroupId;
    data['school_id'] = this.schoolId;
    data['child_standard'] = this.childStandard;
    data['child_division'] = this.childDivision;
    data['child_pickup_address'] = this.childPickupAddress;
    data['child_pickup_latitude'] = this.childPickupLatitude;
    data['child_pickup_longitude'] = this.childPickupLongitude;
    data['actual_pickup_lat_long_added'] = this.actualPickupLatLongAdded;
    data['child_drop_address'] = this.childDropAddress;
    data['child_drop_latitude'] = this.childDropLatitude;
    data['child_drop_longitude'] = this.childDropLongitude;
    data['actual_drop_lat_long_added'] = this.actualDropLatLongAdded;
    data['contract_expiry_date'] = this.contractExpiryDate;
    data['child_photo'] = this.childPhoto;
    data['pickup_person_name'] = this.pickupPersonName;
    data['pickup_person_phone'] = this.pickupPersonPhone;
    data['emergency_contact_no'] = this.emergencyContactNo;
    data['father_mobile_no'] = this.fatherMobileNo;
    data['mother_mobile_no'] = this.motherMobileNo;
    data['pickup_route_id'] = this.pickupRouteId;
    data['drop_route_id'] = this.dropRouteId;
    data['pickup_stop_id'] = this.pickupStopId;
    data['drop_stop_id'] = this.dropStopId;
    data['child_status'] = this.childStatus;
    data['date_created'] = this.dateCreated;
    data['last_modified'] = this.lastModified;
    data['school_name'] = this.schoolName;
    data['show_eta'] = this.shotEta;
    data['school_address'] = this.schoolAddress;
    data['pickup_route_name'] = this.pickupRouteName;
    data['pickup_route_start_time'] = this.pickupRouteStartTime;
    data['pickup_route_end_time'] = this.pickupRouteEndTime;
    data['pickup_route_tracking_type'] = this.pickupRouteTrackingType;
    data['drop_route_name'] = this.dropRouteName;
    data['drop_route_start_time'] = this.dropRouteStartTime;
    data['drop_route_end_time'] = this.dropRouteEndTime;
    data['drop_route_tracking_type'] = this.dropRouteTrackingType;
    data['pickup_attendant_name'] = this.pickupAttendantName;
    data['pickup_attendant_photo'] = this.pickupAttendantPhoto;
    data['pickup_attendant_phone1'] = this.pickupAttendantPhone1;
    data['pickup_attendant_phone2'] = this.pickupAttendantPhone2;
    data['drop_attendant_name'] = this.dropAttendantName;
    data['drop_attendant_photo'] = this.dropAttendantPhoto;
    data['drop_attendant_phone1'] = this.dropAttendantPhone1;
    data['drop_attendant_phone2'] = this.dropAttendantPhone2;
    data['pickup_driver_name'] = this.pickupDriverName;
    data['pickup_driver_photo'] = this.pickupDriverPhoto;
    data['pickup_driver_phone1'] = this.pickupDriverPhone1;
    data['pickup_driver_phone2'] = this.pickupDriverPhone2;
    data['drop_driver_name'] = this.dropDriverName;
    data['drop_driver_photo'] = this.dropDriverPhoto;
    data['drop_driver_phone1'] = this.dropDriverPhone1;
    data['drop_driver_phone2'] = this.dropDriverPhone2;
    data['child_photo_url'] = this.childPhotoUrl;
    data['pickup_vehicle_number'] = this.pickupVehicleNumber;
    data['pickup_vehicle_id'] = this.pickupVehicleId;
    data['drop_vehicle_number'] = this.dropVehicleNumber;
    data['drop_vehicle_id'] = this.dropVehicleId;
    data['track_live_url'] = this.trackLiveUrl;
    data['gala_pickup_url'] = this.galaPickupUrl;
    data['gala_drop_url'] = this.galaDropUrl;
    data['show_payment_button'] = this.showPaymentButton;
    data['child_payment_id'] = this.childPaymentId;
    data['payment_amt'] = this.paymentamt;
    return data;
  }
}

class BannerList {
  String? bannerId;
  String? bannerHeading;
  String? bannerImage;
  String? bannerLink;
  String? bannerType;
  String? schoolList;
  String? dateFrom;
  String? dateTo;
  String? bannerPosition;
  String? bannerStatus;
  String? dateCreated;
  String? lastModified;
  String? bannerImageDisplay;

  BannerList(
      {this.bannerId,
        this.bannerHeading,
        this.bannerImage,
        this.bannerLink,
        this.bannerType,
        this.schoolList,
        this.dateFrom,
        this.dateTo,
        this.bannerPosition,
        this.bannerStatus,
        this.dateCreated,
        this.lastModified,
        this.bannerImageDisplay});

  BannerList.fromJson(Map<String, dynamic> json) {
    bannerId = json['banner_id'];
    bannerHeading = json['banner_heading'];
    bannerImage = json['banner_image'];
    bannerLink = json['banner_link'];
    bannerType = json['banner_type'];
    schoolList = json['school_list'];
    dateFrom = json['date_from'];
    dateTo = json['date_to'];
    bannerPosition = json['banner_position'];
    bannerStatus = json['banner_status'];
    dateCreated = json['date_created'];
    lastModified = json['last_modified'];
    bannerImageDisplay = json['banner_image_display'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['banner_id'] = this.bannerId;
    data['banner_heading'] = this.bannerHeading;
    data['banner_image'] = this.bannerImage;
    data['banner_link'] = this.bannerLink;
    data['banner_type'] = this.bannerType;
    data['school_list'] = this.schoolList;
    data['date_from'] = this.dateFrom;
    data['date_to'] = this.dateTo;
    data['banner_position'] = this.bannerPosition;
    data['banner_status'] = this.bannerStatus;
    data['date_created'] = this.dateCreated;
    data['last_modified'] = this.lastModified;
    data['banner_image_display'] = this.bannerImageDisplay;
    return data;
  }
}
