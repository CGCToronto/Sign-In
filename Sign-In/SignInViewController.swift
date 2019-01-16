//
//  ViewController.swift
//  Sign-In
//
//  Created by Michael Zhang on 2018-12-15.
//  Copyright © 2018 CGCToronto. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class SignInViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]

    private let service = GTLRSheetsService()
    let signInButton = GIDSignInButton()
    let output = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure Google Sign-in.
        if let signIn = GIDSignIn.sharedInstance() {
            signIn.delegate = self
            signIn.uiDelegate = self
            signIn.scopes = scopes
            if signIn.hasAuthInKeychain() {
                signIn.signInSilently()
            }
        } else {
            assertionFailure("Failed to initiate GIDSignIn sharedInstance")
        }

        // Add a UITextView to display output.
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
        view.addSubview(output);

        GIDSignIn.sharedInstance().uiDelegate = self

        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            listMajors()
        }
    }

    // Display (in the UITextView) the names and majors of students in a sample
    // spreadsheet:
    // https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
    func listMajors() {
        output.text = "Getting sheet data..."
        let spreadsheetId = "1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms"
        let range = "Class Data!A2:E"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    // List Google Sheets for selection
    func listUserSheetForSelectionAsDataSource() {
        
    }

    // Process the response and display output
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRSheets_ValueRange,
                                 error : NSError?) {

        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }

        var majorsString = ""
        let rows = result.values!

        if rows.isEmpty {
            output.text = "No data found."
            return
        }

        majorsString += "Name, Major:\n"
        for row in rows {
            let name = row[0]
            let major = row[4]

            majorsString += "\(name), \(major)\n"
        }

        output.text = majorsString
    }



    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }

}

