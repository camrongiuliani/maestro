
![Logo](https://raw.githubusercontent.com/camrongiuliani/maestro/develop/img/logo-white.png)

- [What is Maestro?](#what-is-maestro)
- [What it Isnt](#what-it-isnt)
- [Getting Started](#getting-started)
    - [Application](#maestro-application)
    - [Components](#components)
        - [UseCase](#usecase)
        - [Module](#modules)
            - [UseCases](#usecases)
            - [Slices](#slices)
            - [Routes](#routes)
        - [Service](#services)
    - [Annotations](#maestro-builder)

## What is Maestro?
Maestro is a coordination layer that promotes agnostic design while allowing for communication between its varying components, even if those components are designed as isolated features.

Example Use Case:
You want to create Feature A and Feature B as isolated features (no dependency on each other), without losing the ability to navigate from Feature A to Feature B.

Maestro allows you to do just that, but also allows for the same abstraction of services (data layer) and use-cases (pieces of work).

## What it Isn't
Maestro is not a data flow or design pattern. It is a agnostic coordination layer.

Maestro will work alongside any design pattern you choose to implement.

Example:
You can use BLoC directly in a Maestro Module, or extend the Maestro Module to bring in full BLoC functionality.

## Getting Started
### Maestro Application
The Maestro *Application* class is the base of the framework and acts as a coordinator.

The *Application* will coordinate routing and communication between the various components.

Instantiating:


     Application application = Application();  

*Application* is a static singleton, and can be accessed directly; however, the recommendation is to wrap the application in an *AppWidget* using *App.create()*:


    runApp( App.create(       
        application: application,    
        initialRoute: '',    
    ));   

This allows you to access the *Application* using a familiar access pattern:

    Application.of( context );

Using *App.create* will also allow you to update certain view elements, such as the `statusBarBrightness`:

    application.viewModel.statusBarBrightness.value = Brightness.dark;

or the `AppBar, BottomSheet, BottomNavigation`:

    Application.of( context ).setAppBar( {Any Widget} );


The *Application* by itself does not do much.

To unlock the full potential of *Maestro*, we must register our dependencies so that it knows how to route and behave.

Dependencies ( in this context ) are known as *Components*.

To see if a *Component* is already registered, you can use:

    application.componentExists<MyComponent>(); 

And to access a registered *Component*:

    application.component<MyComponent>();

## Components
*Components* are the building blocks of a Maestro app, and should be designed as isolated as possible.

There are three core components: *UseCases*, *Modules*, and *Services*.

### UseCase
Maestro contains a semi-agnostic [*UseCase* framework](https://github.com/camrongiuliani/use_case).

Used commonly in Clean Architecture, *UseCases* allow for abstraction and reusability of business logic.

In this context, a *UseCase* is a *Component* that contains a method that can be invoked by a caller.

A *UseCase* should **never** have access to the view.

With *Maestro*, once a *UseCase* is registered, it can be used anywhere. You can think of it like an exported function. The caller doesn't know anything about the function, but is allowed to utilize it and react to the *UseCase* state.

*UseCase States*:
> none - UseCase is not being managed.
> 
> queued - UseCase is in the queue and will be executed.
> 
> started - UseCase execution has started.  
> 
> waiting - Waiting for UseCase to finish.
> 
> done - UseCase finished with success.
> 
> error - UseCase finished with errors.

Here is an example *UseCase* that will print a *message* to console:


     class LoggingUseCase extends UseCase {    
      @override    
      String get id => Maestro.useCases.globalLoggingUseCase;    
        
      LoggingUseCase();    
        
      @override    
      FutureOr<void> execute( Map<String, dynamic>? args ) async {    
        if ( args != null && args.containsKey('message') ) {    
          print( 'Maestro Log: ${args['message']}' );    
        }    
      }    
    }  


The above *UseCase* can be called directly:

     LoggingUseCase luc = LoggingUseCase(); 
     luc.execute( { 'message': 'Hi!' } )  

However, it is not recommended because you now have a hard dependency on the *UseCase*.

The recommended approach is to register your *UseCase* with the application.

Registering it with the *Application* will expose its functionality to all *Modules* and *Services*, without forcing them to depend on it (no pubspec requirement).

**Note**: UseCase IDs must be unique if you intend to register them with the *Application*.


Maestro can generate unique IDs for *UseCases* via *maestro_builder*. More on that later.

     // luc.id => 'loggingUseCaseUniqueID' 
     LoggingUseCase luc = LoggingUseCase(); 
     application.registerUseCase( luc  );  


There are multiple ways to execute a *UseCase* once registered, and doing so will add it to a queue.

Maestro iterates that queue and fires each *UseCase* asynchronously.

All *UseCase* statuses (states) are kept in memory until the queue has been depleted.

If you fire the same *UseCase* with equal arguments twice during a queue traversal, the observers watching that *UseCase* are joined.

This means the *UseCase* only fires once but both observers are notified of the status (state & value).

You can execute a without needing the response:

     application.callUseCase( {id} );  

Or with a handler:

    application.callUseCase( {id}, observer: UseCaseHandler(
        onUpdate: ( status ) {}
    ));


A use case can also be converted into a future:  
dynamic x = await application.callUseCaseFuture( Maestro.useCases.loggingUseCase );

or a stream:

     Stream<dynamic> x = await application.callUseCaseStream( Maestro.useCases.loggingUseCase );

The *UseCase* will execute when a listener attaches to the stream.
When the UseCase completes, the stream is closed.

You can also turn any Class (e.g. a BLoC) into an observer, and pass it to the call method:


    class MyBloc extends Bloc implements UseCaseObserver {     

        const MyBloc();     

        @override    
        void onUseCaseUpdate(UseCaseStatus update) {    
          print('MyBloc : ${update.state}');    
        }            
    }  


Lastly, you can subscribe to a specific UseCase:

    class MyBloc extends Bloc implements UseCaseObserver {     
        final Application application;

        late final UseCaseSubscription subs;    
	       
        MyBloc( this.application ) {  
            subs = application.subscribe( Maestro.useCases.loggingUseCase , this ); 
        }

        void init() { 
            application.callUseCase( Maestro.useCases.loggingUseCase ); 
        }
		       
        void dispose() {  
            subs.dispose(); 
        }
		       
        @override    
        void onUseCaseUpdate(UseCaseStatus update) {    
            print('MyBloc : ${update.state}');    
        }    
    }  


In the example above, `onUseCaseUpdate` will fire whenever the logging use case executes, no matter who executed it or what parameters were passed in.

Always call *dispose* on the returned *UseCaseSubscription*.

### Modules

*Modules* contain the UI layer, and should not be hard dependencies of each other.

E.g. ModuleA should never list ModuleB in its pubspec.

*Modules* can access the data layer through *Services*; which **can** be depended on; however.

They also contain routes, *Slices* and *UseCases*; all of which can be exposed to other *Components*.

To create a *Module*, extend the *Module* class and create a singleton constructor:

Example:

	 class MyModule extends Module {    
	     static MyModule? instance;    
       
	     MyModule._(Application application) : super(    
	       application: application,    
	     );    
       
	    factory MyModule([ Application? application ]) {    
	       assert( instance != null || application != null );    
	       return instance ??= MyModule._(application!);    
	    }    
	 }  

Sometimes is is neccesary to initialize a *Module* before it can be used. To that end, the *configureDependencies()* callback is provided, which is async. The *Application* will handle the initialization of the *Module* by first calling this override:

    @override  
    Future configureDependencies() async {}

At this point, you are able to register *MyModule* with the *Application*.


     application.register( MyModule( application ) );   

You can also lazily register any *Component*. This tells the Application that you may use a Module at a later time.

e.g. You may not be able to load a *Module* until the user has authenticated with your backend.

    application.registerAsync( FrameworkComponentBuilder(() => MyModule()) )

Once the user authenticates, you would then call:

    application.loadAsyncComponent<MyModule>()


Registering the example *Module* above will not actually do anything at this point, because we have not told the application what resources the *Module* can expose.

To do that, you need to override some methods:

    @override  
    List<UseCase> buildUseCases() => [];  
      
    @override  
    List<ContentSlice> buildSlices() => [];  
      
    @override  
    List<ContentRoute> buildRoutes() => [];

#### UseCases
*UseCases* are explained [here](#usecases).

A *Module* can provide a *UseCase* to other *Components* by overriding the *buildUseCases()* method:

    @override  
    List<UseCase> buildUseCases() {  
      return [  
        DemoUseCase(),  
      ];  
    }

#### Slices
*Slices* can be thought of as exported Widgets. It gives your *Module* the ability to provide a Widget to other *Modules*, without requiring a hard dependency on your *Module*.

To create a slice, simply extend *ContentType*:

    class DemoSlice extends ContentSlice {  
      
      @override  
      String get id => 'DemoSlice';  
      
      DemoSlice({ required super.owner, });  
      
      @override  
      Widget buildContent([ ViewArgs? args ]) {  
        return Container(  
          color: Colors.red,  
	    );  
      }  
    }   

Much like *UseCases*, *Slices* also require a unique ID.

In the above example, we are simply exposing a Container with a red background.

Tell the *Application* that your *Module* exposes the slice by adding it to the *buildSlices()* method:

    @override  
    List<ContentSlice> buildSlices() {  
      return [  
        DemoSlice(  
          owner: this,  // this = Module
	    ),  
      ];  
    }

Other *Modules* can then access your slice by using the *Slice* widget:

    Slice(  
      sliceID: 'DemoSlice',  
      fallback: SizedBox(), // Default, not required  
      arguments: ViewArgs({map}), // Not required  
    );

If the *Application* locates a *Module* that is exposing the *DemoSlice*, it will render it; however, if that *Slice* does not exist then it will just return a *SizedBox.shrink()*

#### Routes
Similar to *UseCases* and *Slices*, *buildRoutes* will tell the *Application* that your *Module* is capable of handling certain routes.

    @override  
    List<ContentRoute> buildRoutes() {  
      return [  
        ContentRoute(  
          owner: this,  // this = Module
	      routeName: 'MyPage',  
	      builder: ([ args ]) => const MyPage(),  
	    ),  
      ];  
    }

The route itself (*MyPage in this example*) is a basic Flutter widget (stateful or stateless), and does not require any additional setup.

Routing is handled inside of Maestro; however, it uses the basic Flutter navigator.

This means that you should be able to use Maestro routing with other packages such as Modular, should that be desired.

To push a route, it is best to use the *Application* router instance:

    Application.of(context).router.pushNamed( 'routeID' );  

The same is true for popping:

    Application.of(context).router.pop();

*Modules* themselves are route aware, and provide you with the following (optional) overrides:

    Future willPop() async {}  
      
    Future willPush( String route ) async {}  
      
    Future<bool> shouldPop(String routeName, BuildContext? context) {}  
      
    void didPop(Route route, Route? previousRoute) {}  
      
    void didRemove(Route route, Route? previousRoute) {}  
      
    void didReplace({Route? newRoute, Route? oldRoute}) {}  
      
    void didStopUserGesture() {}

The application router is just a wrapper for pure Flutter navigators.

The application has a navigator, as does each Module.

When you **pushNamed**, the application will check to see if there are any modules that can handle the route. If not module exists, then you will land on a 404 (unknown route).

### Services
*Service* creation/registration is similar to that of a *Modules.

A *Service* can be thought of as the data layer.

As stated previously, multiple *Modules* may depend on a service, so it is best to write test to ensure you do not introduce any unwanted changes across your project.

    class OnboardingService extends Service {  
      
     static OnboardingService? instance;  
      
     OnboardingService._( { required super.application } );  
      
     factory OnboardingService( [ Application? application ] ) {  
        assert( instance != null || application != null );  
	    return instance ??= OnboardingService._( application: application! );  
      }  
      
    }

### Maestro Builder




