import Foundation
import UIKit
import React

@objc(CreditCardScannerBridge)
class CreditCardScannerBridge: NSObject {
  
  @objc func scanCard(_ dummy_text: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock)   {
    DispatchQueue.main.async {
      guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
//        rejecter("NO_ROOT_VC", "Could not find root view controller", "error" as! any Error as Error)
        return
      }
      let scannerDelegate = ScannerDelegate(resolver: resolver, rejecter: rejecter)
      let scannerVC = CreditCardScannerViewController(delegate: scannerDelegate)

//      let scannerVC = CreditCardScannerViewController(delegate: ScannerDelegate( resolver: resolver,rejecter: rejecter))
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
    
    if hasCompleted { return }
    complete()  // Mark as completed
    viewController.dismiss(animated: true, completion: nil)
    self.rejecter("error", "Cancelled", NSError(domain: "", code: 0, userInfo: nil))

  }


  func creditCardScannerViewController(_ viewController: CreditCardScannerViewController, didErrorWith error: CreditCardScannerError) {
    print(error);
    if hasCompleted { return }
    complete()  // Mark as completed
    viewController.dismiss(animated: true, completion: nil)
    self.rejecter("error", "failed to scan", NSError(domain: "", code: 0, userInfo: nil))

  }

  func creditCardScannerViewController(_ viewController: CreditCardScannerViewController, didFinishWith card: CreditCard) {
      viewController.dismiss(animated: true, completion: nil)
    print("success")
    print("\(card)")
    print("\(String(describing: card.number))")
    
    
    if hasCompleted { return }
    complete()  // Mark as completed
    self.resolver(card.number)
  }
  
  private let resolver: RCTPromiseResolveBlock
  private let rejecter: RCTPromiseRejectBlock
  private var hasCompleted = false  // Flag to track if resolve/reject is already called


  init(resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
      self.resolver = resolver
      self.rejecter = rejecter
  }


  private func complete() {
      if hasCompleted {
          return
      }
      hasCompleted = true
  }
}
