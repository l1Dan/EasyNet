//
// FastNetwork.h
//
// Copyright (c) 2021 Leo Lee FastNetwork (https://github.com/l1Dan/FastNetwork)
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

#import <Foundation/Foundation.h>

#ifndef FastNetwork_h
#define FastNetwork_h

#if __has_include(<FastNetwork/FastNetwork.h>)

//! Project version number for FastNetwork.
FOUNDATION_EXPORT double FastNetworkVersionNumber;

//! Project version string for FastNetwork.
FOUNDATION_EXPORT const unsigned char FastNetworkVersionString[];

#import <FastNetwork/NSString+FSTConnectTask.h>
#import <FastNetwork/NSURLSession+HTTPProxy.h>
#import <FastNetwork/FSTConnectTask.h>
#import <FastNetwork/FSTInterceptor.h>
#import <FastNetwork/FSTNetworkMediator.h>

#else

#import "NSString+FSTConnectTask.h"
#import "NSURLSession+HTTPProxy.h"
#import "FSTConnectTask.h"
#import "FSTInterceptor.h"
#import "FSTNetworkMediator.h"

#endif /* __has_include */

#endif /* FastNetwork_h */


