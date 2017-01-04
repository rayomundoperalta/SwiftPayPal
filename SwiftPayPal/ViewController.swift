//
//  ViewController.swift
//  SwiftPayPal
//
//  Created by Raymundo Peralta on 1/1/17.
//  Copyright © 2017 Industrias Peta. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PayPalPaymentDelegate {
    
    // For PayPal integration, we need to follow these steps
    // 1. Add Paypal config. in AppDelegate
    // 2. Create PayPal object
    // 3. Declare payment configuration
    // 4. Implement PayPalPaymentDelegate
    // 5. Add payment items and related details
    
    var payPalConfig = PayPalConfiguration()
    
    var enviroment:String = PayPalEnvironmentSandbox {
        willSet(newEnvironment) {
            if (newEnvironment != enviroment) {
                PayPalMobile.preconnectWithEnvironment(newEnvironment)
            }
        }
    }
    
    var acceptCreditCards:Bool = true {
        didSet {
            payPalConfig.acceptCreditCards = acceptCreditCards
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        payPalConfig.acceptCreditCards = acceptCreditCards
        payPalConfig.merchantName = "Industrias PETA S de RL MI"
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "http://peta.mx")
        payPalConfig.merchantUserAgreementURL = NSURL(string: "http://peta.mx")
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages()[0] 
        payPalConfig.payPalShippingAddressOption = .PayPal;
        
        PayPalMobile.preconnectWithEnvironment(enviroment)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }

    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController, didCompletePayment completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            // send completed confirmation to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
        })
    }

    @IBAction func payPressed(sender: AnyObject) {
        
        // Process Payment once the pay button is clicked.
        
        let item1 = PayPalItem(name: "Paquete de 3 avaluos", withQuantity: 1, withPrice: NSDecimalNumber(string: "250.00"), withCurrency: "MXN", withSku: "PETA 00001")
        let items = [item1]
        let subtotal = PayPalItem.totalPriceForItems(items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "0.00")
        let tax = NSDecimalNumber(string: "35.20")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.decimalNumberByAdding(shipping).decimalNumberByAdding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "MXN", shortDescription: "3 estimaciones", intent: .Sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            presentViewController(paymentViewController!, animated: true, completion: nil)
        }
        else {
            print("Payment not processable: \(payment)")
        }
    }
}

