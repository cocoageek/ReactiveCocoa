//
//  RACBindingExamples.m
//  ReactiveCocoa
//
//  Created by Uri Baghin on 30/12/2012.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import "RACBindingExamples.h"

#import "NSObject+RACDeallocating.h"
#import "NSObject+RACPropertySubscribing.h"
#import "RACBinding.h"
#import "RACCompoundDisposable.h"
#import "RACDisposable.h"
#import "RACSignal+Operations.h"

NSString * const RACBindingExamples = @"RACBindingExamples";
NSString * const RACBindingExampleCreateBlock = @"RACBindingExampleCreateBlock";

SharedExampleGroupsBegin(RACBindingExamples)

sharedExamplesFor(RACBindingExamples, ^(NSDictionary *data) {
	__block RACBinding * (^getBinding)(void);
	__block RACBinding *binding;

	id value1 = @"test value 1";
	id value2 = @"test value 2";
	id value3 = @"test value 3";
	NSArray *values = @[ value1, value2, value3 ];
	
	before(^{
		getBinding = data[RACBindingExampleCreateBlock];
		binding = getBinding();
	});
	
	it(@"should send the latest leftEndpoint value on subscription", ^{
		__block id receivedValue = nil;

		[binding.rightEndpoint sendNext:value1];
		[[binding.leftEndpoint take:1] subscribeNext:^(id x) {
			receivedValue = x;
		}];

		expect(receivedValue).to.equal(value1);
		
		[binding.rightEndpoint sendNext:value2];
		[[binding.leftEndpoint take:1] subscribeNext:^(id x) {
			receivedValue = x;
		}];

		expect(receivedValue).to.equal(value2);
	});
	
	it(@"should send the latest rightEndpoint value on subscription", ^{
		__block id receivedValue = nil;

		[binding.leftEndpoint sendNext:value1];
		[[binding.rightEndpoint take:1] subscribeNext:^(id x) {
			receivedValue = x;
		}];

		expect(receivedValue).to.equal(value1);
		
		[binding.leftEndpoint sendNext:value2];
		[[binding.rightEndpoint take:1] subscribeNext:^(id x) {
			receivedValue = x;
		}];

		expect(receivedValue).to.equal(value2);
	});
	
	it(@"should send leftEndpoint values as they change", ^{
		[binding.rightEndpoint sendNext:value1];

		NSMutableArray *receivedValues = [NSMutableArray array];
		[binding.leftEndpoint subscribeNext:^(id x) {
			[receivedValues addObject:x];
		}];

		[binding.rightEndpoint sendNext:value2];
		[binding.rightEndpoint sendNext:value3];
		expect(receivedValues).to.equal(values);
	});
	
	it(@"should send rightEndpoint values as they change", ^{
		[binding.leftEndpoint sendNext:value1];

		NSMutableArray *receivedValues = [NSMutableArray array];
		[binding.rightEndpoint subscribeNext:^(id x) {
			[receivedValues addObject:x];
		}];

		[binding.leftEndpoint sendNext:value2];
		[binding.leftEndpoint sendNext:value3];
		expect(receivedValues).to.equal(values);
	});

	it(@"should complete both signals when the leftEndpoint is completed", ^{
		__block BOOL completedLeft = NO;
		[binding.leftEndpoint subscribeCompleted:^{
			completedLeft = YES;
		}];

		__block BOOL completedRight = NO;
		[binding.rightEndpoint subscribeCompleted:^{
			completedRight = YES;
		}];

		[binding.leftEndpoint sendCompleted];
		expect(completedLeft).to.beTruthy();
		expect(completedRight).to.beTruthy();
	});

	it(@"should complete both signals when the rightEndpoint is completed", ^{
		__block BOOL completedLeft = NO;
		[binding.leftEndpoint subscribeCompleted:^{
			completedLeft = YES;
		}];

		__block BOOL completedRight = NO;
		[binding.rightEndpoint subscribeCompleted:^{
			completedRight = YES;
		}];

		[binding.rightEndpoint sendCompleted];
		expect(completedLeft).to.beTruthy();
		expect(completedRight).to.beTruthy();
	});
});

SharedExampleGroupsEnd