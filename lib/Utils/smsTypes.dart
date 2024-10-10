enum SMSType { forgotPassword, customerRedemption, vendorActivation }

int getSMSType(SMSType type) {
  switch (type) {
    case SMSType.forgotPassword:
      return 1;
    case SMSType.customerRedemption:
      return 3;
    case SMSType.vendorActivation:
      return 4;
    default:
      return 0;
  }
}
