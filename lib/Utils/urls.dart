class Urls {
  //static const baseUrl = "http://143.110.181.12:7070/api/";
  static const baseUrl = "https://sacrosys.net:6662/api/";
  static const login = "${baseUrl}2878/Verification";
  static const categories = "${baseUrl}8363/getVendorClassifications";
  static const stores = "${baseUrl}8363/getApprovedVendorsForFlutter";
  static const storesbyCalssification =
      "${baseUrl}8363/getApprovedVendorsbyClassification";
  static const register = "${baseUrl}2878/postCustomerActivation";
  static const sendOtp = "${baseUrl}5678/sendOtp";
  static const uploadImage = "${baseUrl}9132/ImageUpload";
  static const checkCustomerEligible = "${baseUrl}2878/IsCustomerEligibile";
  static const postRewards = "${baseUrl}7392/PostRewards"; //todo noted
  static const resetPassword = "${baseUrl}2878/resetPassword";
  static const getProfileData = "${baseUrl}2878/getProfileData";
  static const updateProfileData = "${baseUrl}2878/updateProfile";
  static const getPlaceData = "${baseUrl}8363/getPlacesAndTown";
  static const getApprovedVendorsByPlace =
      "${baseUrl}8363/getApprovedVendorsbyPlaces";

  static const postRedeem = "${baseUrl}7392/PostRedeems";
  static const postReward = "${baseUrl}7392/PostRewards";
  static const getVendorActivationCheck =
      "${baseUrl}8363/getVendorActivationCheck";
  static const setVendorPassword = "${baseUrl}8363/setVendorPassword";
  static const reSetVendorPassword = "${baseUrl}8363/resetVendorPassword";
  static const vendorTransactions =
      "${baseUrl}8363/getLast10VendorTransactions";

  static const verificationByCardNumber =
      "${baseUrl}2878/VerificationByCardNumber";
  static const isCustomerEligible = "${baseUrl}2878/IsCustomerEligibile";
  static const isCustomerEligibileByCardNumber =
      "${baseUrl}2878/IsCustomerEligibileByCardNumber";

  static const getAppConfig = "${baseUrl}7263/getAppConfig";
}
// "http://sacrosys.net:6662/api/2878/IsCustomerEligibile";