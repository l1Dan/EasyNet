//
// EasyNet+Rx.swift
//
// Copyright (c) 2021 Leo Lee EasyNet (https://github.com/l1Dan/EasyNet)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import RxSwift

#if !COCOAPODS
import EasyNet
#endif

extension Reactive where Base: ENConnectTask {
    
    public func start() -> Single<ENConnectTask> {
        return Single<ENConnectTask>.create { single in
            base.start { task in
                single(.success(task))
            } failure: { task in
                let error = NSError(domain: "com.github.l1Dan.RxEasyNetDomain", code: -1, userInfo: nil)
                single(.failure(task.responseError ?? error))
            }
            return Disposables.create {
                base.stop()
            }
        }
    }
    
    public func start(withConvert convert: AnyClass) -> Single<ENConnectTask> {
        return Single<ENConnectTask>.create { single in
            base.start(withConvert: convert) { task in
                single(.success(task))
            } failure: { task in
                let error = NSError(domain: "com.github.l1Dan.RxEasyNetDomain", code: -1, userInfo: nil)
                single(.failure(task.responseError ?? error))
            }
            return Disposables.create {
                base.stop()
            }
        }
    }
    
}
