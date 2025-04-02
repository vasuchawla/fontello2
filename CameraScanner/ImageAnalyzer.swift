//
//  ImageAnalyzer.swift
//
//
//  Created by miyasaka on 2020/07/30.
//

import Foundation

#if canImport(Vision)
import Vision

protocol ImageAnalyzerProtocol: AnyObject {
    func didFinishAnalyzation(with result: Result<CreditCard, CreditCardScannerError>)
}

@available(iOS 13, *)
final class ImageAnalyzer {
    enum Candidate: Hashable {
        case number(String), name(String)
        case expireDate(DateComponents)
    }

    typealias PredictedCount = Int

    private var selectedCard = CreditCard()
    private var predictedCardInfo: [Candidate: PredictedCount] = [:]

    private   var delegate: ImageAnalyzerProtocol?
    init(delegate: ImageAnalyzerProtocol) {
      print( delegate)
        self.delegate = delegate
    }

    // MARK: - Vision-related

    public lazy var request = VNRecognizeTextRequest(completionHandler: requestHandler)
    func analyze(image: CGImage) {
        let requestHandler = VNImageRequestHandler(
            cgImage: image,
            orientation: .up,
            options: [:]
        )
      request.usesLanguageCorrection = false

      
        do {
            try requestHandler.perform([request])
        } catch {
            let e = CreditCardScannerError(kind: .photoProcessing, underlyingError: error)
            delegate?.didFinishAnalyzation(with: .failure(e))
            delegate = nil
        }
    }
  
  

    lazy var requestHandler: ((VNRequest, Error?) -> Void)? = { [weak self] request, _ in
      guard let strongSelf = self else { return }

      let creditCardNumber: Regex = #"(?:\d[ -]*?){13,16}"#
      let month: Regex = #"(\d{2})\/\d{2}"#
      let year: Regex = #"\d{2}\/(\d{2})"#
      let wordsToSkip = ["mastercard", "jcb", "visa", "express", "bank", "card", "platinum", "reward"]
      // These may be contained in the date strings, so ignore them only for names
      let invalidNames = ["expiration", "valid", "since", "from", "until", "month", "year"]
      let name: Regex = #"([A-z]{2,}\h([A-z.]+\h)?[A-z]{2,})"#
    

      guard let results = request.results as? [VNRecognizedTextObservation] else { return }
    
      var creditCard = CreditCard(number: nil, name: nil, expireDate: nil)

      for observation in results {
          if let topCandidate = observation.topCandidates(1).first {
              let text = topCandidate.string
              // Process text - check if it matches credit card pattern
              if  isCreditCardNumber(text) {
                  print("Detected credit card: \(text)")
                let cardNumber2 = text
                    .replacingOccurrences(of: " ", with: "")
                    .replacingOccurrences(of: "-", with: "")
                    .replacingOccurrences(of: ".", with: "")
                    .replacingOccurrences(of: ",", with: "")
                  creditCard.number = cardNumber2
                      strongSelf.selectedCard.number = cardNumber2
                  // Handle the credit card number appropriately
                if strongSelf.selectedCard.number != nil {
                  print(strongSelf.delegate ?? "nill strong self delegate")
                  print(self?.delegate ?? "nil self delegate")
                    strongSelf.delegate?.didFinishAnalyzation(with: .success(strongSelf.selectedCard))
                    strongSelf.delegate = nil
                }
              }
          }
      }
      
      
      
      func isCreditCardNumber(_ string: String) -> Bool {
        
        let allowedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: " .,"))

        // Check if the input contains any invalid characters
         if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
             return false // Contains invalid characters
         }
        
        print(string)
        // Remove spaces, dots, and commas to extract only digits
        let digitsOnly = string.replacingOccurrences(of: " ", with: "")
                                .replacingOccurrences(of: ".", with: "")
                                .replacingOccurrences(of: ",", with: "")
        
          // Check if the string has a valid length for a credit card (usually 13-19 digits)
          if digitsOnly.count < 13 || digitsOnly.count > 19 {
              return false
          }
          
          // Implement Luhn algorithm to validate credit card number
          // This is a basic check many credit card processors use
          var sum = 0
          let digits = digitsOnly.reversed().map { Int(String($0))! }
          
          for (index, digit) in digits.enumerated() {
              if index % 2 == 1 {
                  let doubled = digit * 2
                  sum += doubled > 9 ? doubled - 9 : doubled
              } else {
                  sum += digit
              }
          }
          
          return sum % 10 == 0
      }
      
      
      
//      print("------------------")
//      print("------------------")
//      print("------------------")
//      print("------------------")
//      print("------------------")
//      print("------------------")
      
//      for result in results {
//          if let topCandidate = result.topCandidates(1).first {
//              print(topCandidate.string)
//          }
//      }
      
      
//      for result in results {
//          if let topCandidate = result.topCandidates(1).first {
//              let recognizedText = topCandidate.string
//              print("Recognized Text: \(recognizedText)")
//
//              // Regex to detect a potential card number (13 to 19 digits)
//              let cardNumberPattern = "\\b\\d{13,19}\\b"
//              
//            if let cardNumber = extractMatch(from: recognizedText, pattern: cardNumberPattern) {
//                  print("Detected Card Number: \(cardNumber)")
//              let cardNumber2 = cardNumber
//                  .replacingOccurrences(of: " ", with: "")
//                  .replacingOccurrences(of: "-", with: "")
//                creditCard.number = cardNumber2
//                    strongSelf.selectedCard.number = cardNumber2
//             
//              }
//           
//              
//              
//              
//          }
//      }
//   
      
      // Function to extract a number matching the pattern
//      func extractMatch(from text: String, pattern: String) -> String? {
//          let regex = try? NSRegularExpression(pattern: pattern)
//          let range = NSRange(text.startIndex..., in: text)
//          
//          if let match = regex?.firstMatch(in: text, options: [], range: range) {
//              if let range = Range(match.range, in: text) {
//                  return String(text[range])
//              }
//          }
//          return nil
//      }
//      
//      
      
//        let maxCandidates = 1
//        for result in results {
//            guard
//                let candidate = result.topCandidates(maxCandidates).first,
//                candidate.confidence > 0.1
//            else { continue }
//
//            let string = candidate.string
//            let containsWordToSkip = wordsToSkip.contains { string.lowercased().contains($0) }
//            if containsWordToSkip { continue }
//
//            if let cardNumber = creditCardNumber.firstMatch(in: string)?
//                .replacingOccurrences(of: " ", with: "")
//                .replacingOccurrences(of: "-", with: "") {
//                creditCard.number = cardNumber
//
//                // the first capture is the entire regex match, so using the last
//            } else if let month = month.captures(in: string).last.flatMap(Int.init),
//                // Appending 20 to year is necessary to get correct century
//                let year = year.captures(in: string).last.flatMap({ Int("20" + $0) }) {
//                creditCard.expireDate = DateComponents(year: year, month: month)
//
//            } else if let name = name.firstMatch(in: string) {
//                let containsInvalidName = invalidNames.contains { name.lowercased().contains($0) }
//                if containsInvalidName { continue }
//                creditCard.name = name
//
//            } else {
//                continue
//            }
//        }
//
//        // Name
//        if let name = creditCard.name {
//            let count = strongSelf.predictedCardInfo[.name(name), default: 0]
//            strongSelf.predictedCardInfo[.name(name)] = count + 1
//            if count > 2 {
//                strongSelf.selectedCard.name = name
//            }
//        }
//        // ExpireDate
//        if let date = creditCard.expireDate {
//            let count = strongSelf.predictedCardInfo[.expireDate(date), default: 0]
//            strongSelf.predictedCardInfo[.expireDate(date)] = count + 1
//            if count > 2 {
//                strongSelf.selectedCard.expireDate = date
//            }
//        }
//
//        // Number
//        if let number = creditCard.number {
//            let count = strongSelf.predictedCardInfo[.number(number), default: 0]
//            strongSelf.predictedCardInfo[.number(number)] = count + 1
//            if count > 2 {
//                strongSelf.selectedCard.number = number
//            }
//        }

      
    }
}
#endif
