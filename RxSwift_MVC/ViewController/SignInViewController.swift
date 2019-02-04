//
//  ViewController.swift
//  RxSwift_Example
//
//  Created by 이광용 on 02/02/2019.
//  Copyright © 2019 GwangYongLee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignInViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailValidationView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordValidationView: UIView!
    @IBOutlet weak var signInButton: UIButton!
    
    let emailTextSubject = BehaviorSubject(value: "")
    let passwordTextSubject = BehaviorSubject(value: "")
    let emailValidationSubject = BehaviorSubject(value: false)
    let passwordValidationSubject = BehaviorSubject(value: false)
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindInput()
        bindOutput()
    }

    private func bindInput() {
        emailTextField.rx.text.orEmpty
            .skip(1)
            .bind(to: emailTextSubject)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .skip(1)
            .bind(to: passwordTextSubject)
            .disposed(by: disposeBag)
        
        emailTextSubject.asObservable()
            .map(validateEmail)
            .bind(to: emailValidationSubject)
            .disposed(by: disposeBag)
        
        passwordTextSubject.asObservable()
            .map(validatePassword)
            .bind(to: passwordValidationSubject)
            .disposed(by: disposeBag)
        
        signInButton.rx.tap
            .debounce(1.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: nil)
            .disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        emailTextSubject
            .subscribe(onNext: { self.emailValidationView.isHidden = $0.isEmpty })
            .disposed(by: disposeBag)

        emailValidationSubject
            .subscribe(onNext: { self.emailValidationView.backgroundColor = $0 ? .green : .red })
            .disposed(by: disposeBag)
        
        passwordTextSubject
            .subscribe(onNext: { self.passwordValidationView.isHidden = $0.isEmpty })
            .disposed(by: disposeBag)
        
        passwordValidationSubject
            .subscribe(onNext: { self.passwordValidationView.backgroundColor = $0 ? .green : .red })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(emailValidationSubject, passwordValidationSubject) { $0 && $1 }
            .subscribe(onNext: { self.signInButton.isEnabled = $0 })
            .disposed(by: disposeBag)
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    private func validatePassword(_ password: String) -> Bool {
        return 5 < password.count
    }
    
    private func requestSignIn(email: String, password: String) {
        
    }
}
