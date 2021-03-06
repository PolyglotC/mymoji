//  Copyright © 2017 Stacey Dao. All rights reserved.

import UIKit
import Messages

class MessagesAppViewController: MSMessagesAppViewController {

    var selectedCategory: Category?

    var categoryViewController: CategoryViewController? {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: CategoryViewController.Constants.storyboardIdentifier) as? CategoryViewController else { return nil }
        vc.delegate = self
        return vc
    }

    var listViewController: MymojiListViewController? {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: MymojiListViewController.Constants.storyboardIdentifier) as? MymojiListViewController else { return nil }
        vc.delegate = self
        return vc
    }

    func presentRatingsViewController(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle){
        let nextViewController: UIViewController
        switch presentationStyle {
        case .compact:
            guard let categoryViewController = categoryViewController else { return }
            nextViewController = categoryViewController
        default:
            guard let listViewController = listViewController,
                let category = selectedCategory else { return }
            listViewController.category = category
            nextViewController = listViewController
        }
        add(nextViewController)
    }

    func add(_ nextViewController: UIViewController) {
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }

        addChildViewController(nextViewController)
        nextViewController.view.frame = view.bounds
        nextViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextViewController.view)

        nextViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        nextViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        nextViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        nextViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        nextViewController.didMove(toParentViewController: self)
    }

    // Compose message and layout
    private func composeMessage(image: UIImage?, session: MSSession? = nil) -> MSMessage? {
        guard let image = image else { return nil }
        let layout = MSMessageTemplateLayout()
        layout.image = image
        let message = MSMessage(session: session ?? MSSession())
        message.shouldExpire = false
        message.layout = layout
        return message
    }

    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.

        presentRatingsViewController(for: conversation, with: self.presentationStyle)
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.

        guard let conversation = activeConversation else { fatalError("Expected an active converstation") }

        presentRatingsViewController(for: conversation, with: presentationStyle)
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
}

extension MessagesAppViewController: CategoryViewControllerDelegate {
    func emotionViewController(_: CategoryViewController, didSelect category: Category) {
        selectedCategory = category
        requestPresentationStyle(.expanded)
    }
}

extension MessagesAppViewController: MymojiViewControllerDelegate {
    func send(mymoji: Mymoji) {
        guard let conversation = activeConversation,
            let message = composeMessage(image: mymoji.image, session: conversation.selectedMessage?.session) else { return }

        // Add the message to the conversation.
        conversation.insert(message) { error in
            if let error = error {
                print("Error inserting message: \(error)")
            }
        }

        dismiss()
    }
}
