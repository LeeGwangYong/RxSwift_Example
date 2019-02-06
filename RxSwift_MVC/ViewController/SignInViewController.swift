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
        
        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        view.addGestureRecognizer(tapBackground)
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
        
        let validations = Observable.combineLatest(emailValidationSubject, passwordValidationSubject) { $0 && $1 }
        validations
            .subscribe(onNext: { self.signInButton.isEnabled = $0 })
            .disposed(by: disposeBag)
        
        let texts = Observable.combineLatest(emailTextSubject, passwordTextSubject) { ($0, $1) }
        
        Observable.merge(signInButton.rx.tap.asObservable(), passwordTextField.rx.controlEvent(.editingDidEndOnExit).asObservable())
            .withLatestFrom(validations)
            .filter{ $0 }
            .withLatestFrom(texts)
            .flatMapLatest{ self.requestSignIn(email: $0, password: $1) }
            .subscribe(onNext: { print($0) },
                       onError: { print($0) })
            .disposed(by: disposeBag)
    }
    
    private func validateEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    private func validatePassword(_ password: String) -> Bool {
        return 5 < password.count
    }
    
    func requestSignIn(email: String, password: String) -> Observable<[String: String]> {
        return URLSession.shared.rx.json(from: SignAPI.in(email: email, password: password))
            .observeOn(CurrentThreadScheduler.instance)
            .map{ $0 as? [String: String] ?? [:] }
    }
}
