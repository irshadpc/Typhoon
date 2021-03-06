////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2014, Jasper Blues & Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "TyphoonFactoryProvider.h"

#import <SenTestingKit/SenTestingKit.h>

#import "AuthServiceImpl.h"
#import "CreditServiceImpl.h"
#import "PaymentFactory.h"
#import "PaymentFactoryAssembly.h"
#import "PaymentImpl.h"
#import "PizzaFactory.h"
#import "PizzaImpl.h"

@interface TyphoonFactoryProviderIntegrationTest : SenTestCase
@end

@implementation TyphoonFactoryProviderIntegrationTest
{
    TyphoonBlockComponentFactory* componentFactory;
    PaymentFactoryAssembly* assembly;
}

- (void)setUp
{
    componentFactory = [[TyphoonBlockComponentFactory alloc] initWithAssembly:[PaymentFactoryAssembly assembly]];
    assembly = (PaymentFactoryAssembly*) componentFactory;
}

- (void)test_dependencies_are_built_lazily
{
    NSUInteger authServiceInstanceCounter = [AuthServiceImpl instanceCounter];
    NSUInteger creditServiceInstanceCounter = [CreditServiceImpl instanceCounter];

    id<PaymentFactory> factory = [assembly paymentFactory];

    assertThatUnsignedInteger([AuthServiceImpl instanceCounter], is(equalToUnsignedInteger(authServiceInstanceCounter)));
    assertThatUnsignedInteger([CreditServiceImpl instanceCounter], is(equalToUnsignedInteger(creditServiceInstanceCounter)));

    // No need for the return value.
    [factory paymentWithStartDate:[NSDate date] amount:123];

    assertThatUnsignedInteger([AuthServiceImpl instanceCounter], is(equalToUnsignedInteger(authServiceInstanceCounter + 1)));
    assertThatUnsignedInteger([CreditServiceImpl instanceCounter], is(equalToUnsignedInteger(creditServiceInstanceCounter + 1)));
}

- (void)test_assisted_factory_is_TyphoonComponentFactoryAware
{
    NSObject<PaymentFactory>* factory = [assembly paymentFactory];

    id cf = [factory valueForKey:@"componentFactory"];
    assertThat(cf, is(equalTo(componentFactory)));
}

- (void)test_assisted_initializer_factory_injects_component_factory_in_object_instances
{
    id<PaymentFactory> factory = [assembly paymentFactory];

    PaymentImpl* payment = [factory paymentWithStartDate:[NSDate date] amount:456];

    assertThat(payment.factory, is(equalTo(componentFactory)));
}

- (void)test_assisted_block_factory_injects_component_factory_in_object_instances
{
    id<PizzaFactory> factory = [assembly pizzaFactory];

    PizzaImpl* pizza = [factory largePizzaWithIngredients:@[@"bacon", @"cheese"]];

    assertThat(pizza.factory, is(equalTo(componentFactory)));
}

@end
