//: Please build the scheme 'RxSwiftPlayground' first
import RxSwift
import PlaygroundSupport

//PlaygroundPage.current.needsIndefiniteExecution = true


/*:
 Copyright (c) 2014-2017 Razeware LLC
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */


//: PUBLISH SUBJECT
example(of: "Published Subject") {
  
  let disposeBag = DisposeBag()
  let subject = PublishSubject<String>()
  subject.onNext("Is anyone Listening")
  
  let subscriptionOne = subject.subscribe(onNext: { (string) in
    print(string)
  })
  subject.on(.next("1"))
  subject.onNext("2")
  // inscription de Two apres event 2
  let subscriptionTwo = subject.subscribe { event in
    print("2)", event.element ?? event)
  }
  // One et Two recoivent 3
  subject.onNext("3")
  
  // desinscription de one
  subscriptionOne.dispose()
  // Uniquement Two recoit 4
  subject.onNext("4")
  
  // Le sujet arrete d emettre
  subject.onCompleted()
  
  // Comme completed le sujet n emet pas
  subject.onNext("5")
  
  // desinscription de Two
  subscriptionTwo.dispose()
  
  // On cree un troisieme observer qui ecoute l emission et stocke dans le dispose bag
  subject.subscribe {
    print("3)", $0.element ?? $0)
  }.disposed(by: disposeBag)
  
  // Meme si on envoie un ordre d emission le subject est completed donc en remet plus après le completed
  subject.onNext("?")
}

//: BEHAVIOR SUBJECT

enum MyError: Error {
  case anError
}

func print<T:CustomStringConvertible>(label: String, event: Event<T>) {
  
  print(label, event.element ?? event.error ?? event)
}

example(of: "behavior subject") {
  let behave = BehaviorSubject(value: "Initial Value")
  
  let disposeBag = DisposeBag()
  behave.subscribe {
    print(label: "1)", event: $0)
  }.disposed(by: disposeBag)
  
  behave.onNext("X")
  behave.onError(MyError.anError)
  
  behave.subscribe {
    print(label: "2)", event: $0)
  }
}

//: REPLAY SUBJECT

example(of: "Replay") {
  // taille du buffer n - 2
  let replay = ReplaySubject<String>.create(bufferSize: 2)
  
  let disposeBag = DisposeBag()
  
  // J envoie 3 emission, les 1 et 2 sont stocké dans buffer au moment ou 3 est emit.
  replay.onNext("1")
  replay.onNext("2")
  replay.onNext("3")
  
  // 2 et 3 passe en buffer
  replay.subscribe {
    print(label: "1)",event: $0)
  }.disposed(by: disposeBag)
  
  replay.subscribe {
    print(label: "2)",event: $0)
  }.disposed(by: disposeBag)
  
  replay.onNext("4")
  replay.subscribe {
    print(label: "3)", event: $0)
  }.disposed(by: disposeBag)

  replay.dispose()
  
  replay.subscribe {
    print(label: "4)", event: $0)
  }
}
example(of: "Variable") {
  let variable = Variable("Initial value")
  
  let disposeBag = DisposeBag()
  
  variable.value = "second value"
  // je cast la variable en observable
  variable.asObservable()
    .subscribe {
      print(label: "1)", event: $0)
  }.disposed(by: disposeBag)
  
  variable.value = "1"
  variable.asObservable()
    .subscribe {
      print(label: "2)", event: $0)
  }.disposed(by: disposeBag)
  
  // quand je change la valeur de la variable j emet
  variable.value = "2"
  
  
  
  
  
  
  
  
  
  
  
}
