import 'package:get_storage/get_storage.dart';

class SharedPreference {
  final storage = GetStorage();

    void clearAllData() {
    storage.erase();
  }

    void setLoggedIn(bool status) {
    storage.write("Logged_in", status);
  }

  bool getLoggedIn() {
    return storage.read("Logged_in") != null
        ? storage.read("Logged_in")
        : false;
  }

  void setVendorActivated(bool status) {
    storage.write("Activated", status);
  }

  bool getVendorActivated() {
    return storage.read("Activated") ? storage.read("Activated") : false;
  }

  void setVendorWalletBalance(String name) {
    storage.write("vendorWalletBalance", name);
  }

  String getVendorWalletBalance() {
    return storage.read('vendorWalletBalance');
  }

   void setVendorMobileNumber(String name) {
    storage.write("vendorRegisteredMobileNumber", name);
  }

  String getVendorMobileNumber() {
    return storage.read('vendorRegisteredMobileNumber');
  }

   void setVendorBussinessName(String name) {
    storage.write("vendorBusinessName", name);
  }

  String getVendorBussinessName() {
    return storage.read('vendorBusinessName');
  }

   void setVendorBranchName(String name) {
    storage.write("vendorBranchName", name);
  }

    String getVendorAddressL1() {
    return storage.read('vendorAddressL1');
  }

  void setVendorAddressL1(String name) {
    storage.write("vendorAddressL1", name);
  }
    String getVendorBranchName() {
    return storage.read('vendorBranchName');
  }

   void setVendorPinCode(String name) {
    storage.write("vendorPinCode", name);
  }

  String getVendorPinCode() {
    return storage.read('vendorPinCode');
  }

//password
  void setVendorSecret(String name) {
    storage.write("password", name);
  }

  String getVendorSecret() {
    return storage.read('password');
  }

  void setVendorId(String id) {
    storage.write("id", id);
  }

  String getVendorId() {
    return storage.read("id");
  }


  void setVendorDeviceId(String id) {
    storage.write("id", id);
  }

  String getVendorDeviceId() {
    return storage.read("id");
  }



  void setCompanyCommision(String commission){
    storage.write("company_commission", commission);
  }

  String getCompanyCommision(){
    return storage.read("company_commission");
  }

// void setMinimumRedemptionAmount(num Amount){
//     storage.write("MinimumRedemptionAmout", Amount);
//   }

//   num getMinimumRedemptionAmount(){
//     return storage.read("MinimumRedemptionAmout");
//   }

// void setMaximumRedemptionAmount(num Amount){
//     storage.write("MaximumRedemptionAmout", Amount);
//   }

//   num getMaximumRedemptionAmount(){
//     return storage.read("MaximumRedemptionAmout");
//   }


}
