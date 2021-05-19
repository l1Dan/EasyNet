//
// EasyNet.h
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

#import <Foundation/Foundation.h>

#ifndef EasyNet_h
#define EasyNet_h

#if __has_include(<EasyNet/EasyNet.h>)

//! Project version number for EasyNet.
FOUNDATION_EXPORT double EasyNetVersionNumber;

//! Project version string for EasyNet.
FOUNDATION_EXPORT const unsigned char EasyNetVersionString[];

#import <EasyNet/ENConnectTask.h>
#import <EasyNet/ENInterceptor.h>
#import <EasyNet/ENNetworkAgent.h>
#import <EasyNet/NSString+ENConnectTask.h>
#import <EasyNet/NSURLSession+HTTPProxy.h>

#else

#import "ENConnectTask.h"
#import "ENInterceptor.h"
#import "ENNetworkAgent.h"
#import "NSString+ENConnectTask.h"
#import "NSURLSession+HTTPProxy.h"

#endif /* __has_include */

#endif /* EasyNet_h */


