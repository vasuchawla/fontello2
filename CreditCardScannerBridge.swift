import Foundation
import UIKit


@objc(CreditCardScannerBridge)
class CreditCardScannerBridge: NSObject {
  
  @objc func scanCard() {
    DispatchQueue.main.async {
      guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
//        rejecter("NO_ROOT_VC", "Could not find root view controller", "error" as! any Error as Error)
        return
      }

      let scannerVC = CreditCardScannerViewController(delegate: ScannerDelegate( ))
      rootViewController.present(scannerVC, animated: true)
    }
  }

  @objc static func requiresMainQueueSetup() -> Bool {
    return true
  }
}

// MARK: - Delegate for Credit Card Scanner
class ScannerDelegate: NSObject, CreditCardScannerViewControllerDelegate {
  func creditCardScannerViewControllerDidCancel(_ viewController: CreditCardScannerViewController) {
    viewController.dismiss(animated: true, completion: nil)
        print("cancel")
  }


  func creditCardScannerViewController(_ viewController: CreditCardScannerViewController, didErrorWith error: CreditCardScannerError) {
      print(error.errorDescription ?? "")
//      resultLabel.text = error.errorDescription
    print("failed")
    print(error.errorDescription ?? "failed msg")
      viewController.dismiss(animated: true, completion: nil)
  }

  func creditCardScannerViewController(_ viewController: CreditCardScannerViewController, didFinishWith card: CreditCard) {
      viewController.dismiss(animated: true, completion: nil)
    print("success")
      // var dateComponents = card.expireDate
      // dateComponents?.calendar = Calendar.current
      // let dateFormater = DateFormatter()
      // dateFormater.dateStyle = .short
      // let date = dateComponents?.date.flatMap(dateFormater.string)

      // let text = [card.number, date, card.name]
      //     .compactMap { $0 }
      //     .joined(separator: "\n")
      // resultLabel.text = text
      print("\(card)")
  }
  
      
    //  let resolver: RCTPromiseResolveBlock
    //  let rejecter: RCTPromiseRejectBlock

  override init() {
    //    self.resolver = resolver
    //    self.rejecter = rejecter
  }

  //   @available(iOS 13, *)
  //   func creditCardScannerViewController(_ viewController: CreditCardScannerViewController, didErrorWith error: CreditCardScannerError) {
  //     viewController.dismiss(animated: true)
  // //    rejecter("SCANNER_ERROR", error.errorDescription ?? "Unknown scanner error",  "error" as! any Error as Error)
  //   }

  //   func creditCardScannerViewController(_ viewController: CreditCardScannerViewController, didFinishWith card: CreditCard) {
  //     viewController.dismiss(animated: true)
      
  //     let cardData: [String: Any] = [
  //       "number": card.number ?? "",
  // //      "expiryMonth": card. card.expiryMonth ?? 0,
  // //      "expiryYear": card.expiryYear ?? 0,
        
  //     ]
  //     print(card.number ?? "dddd")
  //     print(cardData)
      
  // //    resolver(cardData)
  //   }
}
