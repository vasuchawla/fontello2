#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(CreditCardScannerBridge, NSObject)

//RCT_EXTERN_METHOD(scanCard)

RCT_EXTERN_METHOD(
                  scanCard:(NSString *)dummy_text
  resolver:(RCTPromiseResolveBlock)resolve
  rejecter:(RCTPromiseRejectBlock)reject
)


 
@end
