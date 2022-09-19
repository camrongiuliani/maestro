# Mestro
![Logo](https://raw.githubusercontent.com/camrongiuliani/maestro/develop/img/logo-white.png)

- [What is Maestro?](#what-is-maestro)
- [Getting Started](#getting-started)
    - [Application](#maestro-application)
    - [Components](#components)
        - [Module](#modules)
        - [Service](#modules)
        - [UseCase](#modules)
    - [Routing](#routing)

## What is Maestro?
Maestro is a coordination layer that promotes agnostic design while allowing for communication between its varying components, even if those components are designed as isolated features.

## What it Isn't
Maestro is not a design pattern.

In fact, Maestro will work with any design pattern you choose to implement; whether BLoC, MVVM, MVP or Clean Architecture.

This is possible because Maestro is written in (nearly) pure Dart/Flutter and is intended for use at a lower level than your design pattern.

## Getting Started
#### Maestro Application
The Maestro *Application* class is the base of the framework.

One of the tools it uses for making things agnostic is build_runner, so when you are ready to instantiate your Application class, go ahead and add your MaestroApp annotation:

    @MaestroApp()  
	class ExampleApp { ... }

This annotation takes in a few different things, which will be covered later.

Now go ahead instantiate a Maestro Application:

    Application application = Application();

After that, we will need to register our dependencies as singletons. Modules and Services will be discussed further down in the guide.

    application.register( MyModule( application ) );  
    application.register( MyService( application ) );

And then finally:

    await application.init();

The Application class is a Static Singleton and can be accessed directly; however, it is recommended to make use of the App.create widget.

    runApp( App.create(  
	  application: application,  
	  initialRoute: Maestro.routes.onboardingStoreFront,  
	) );

Full example:

    @MaestroApp()  
	void main() async {  
	  
	  WidgetsFlutterBinding.ensureInitialized();  
	  
	  Application application = Application();  
	  
	  application.register( MyModule( application ) );  
	  application.register( MyService( application ) );  
	  
	 await application.init();  
	  
	  runApp( App.create(  
	    application: application,  
	  initialRoute: Maestro.routes.onboardingStoreFront,  
	  ) );  
	}

#### Components
Dependencies within Maestro are referred to as Components, and there are three types:

##### Modules

Modules contain the UI layer, and should not be hard dependencies of each other.

Modules access the data layer through Services; which **can** be depended on.

They also contain routes, slices and use-cases; all of which can be exposed to other Components.

To create a Module, extend the Module class and add the singleton constructor:

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

At this point, you are able to register *MyModule* with Maestro. Add this line where you instantiated the Application.

    application.register( MyModule( application ) );  

This won't actually do anything though, because we have not told the application what the module exposes.

To do that, update your MaestroApp annotation:

    @FrameworkApp(  
	  modules: [  
	    MyModule,  
	  ],  
	)

Once that is done, go ahead and annotate your module with *MaestroModule*, telling the Application which routes you are going to expose:

    @MaestroModule(  
	  baseRoute: 'my_route',  
	  childRoutes: [  
	    'landing',  
	  ],  
	)
	class MyModule extends Module { ... }

In this example, we are informing the application about the routes that this module can handle. The base route is **my_route**, which exposes a single **childRoute** named 'landing.'

In short, we are simply *exposing routes*, allowing one module to directly route to another.

#### Routing

Routing is handled inside of Maestro; however, it uses the basic Flutter navigator. That means that you should be able to use Maestro routing with other packages such as Modular, should that be desired.

To enable routing between Modules without introducing a hard dependency, we can use maestro_builder code generation.

Maestro_Builder

Make sure to always run build_runner after updating annotations:

    flutter pub run build_runner build --delete-conflicting-outputs

After running build_runner, you should see a part file that contains your exposed route name:

    // ********************************  
	// Maestro Routes  
	// ********************************  
	  
	class _Routes {  
	  const _Routes();  
	  
	 final String myModuleMyRoute = '/my_route/landing';  
	}

You are now able to route to your module from any registered Module, without requiring a hard dependency.

    application.router.pushNamed( Maestro.routes.myModuleMyRoute , arguments: {} );

The application router is just a wrapper for pure Flutter navigators. The application has a navigator, as does each Module.

When you **pushNamed**, the application will check to see if there are any modules that can handle the route. If not module exists, then you will land on a 404.

Here is the logical flow for routing:
![Routing](https://raw.githubusercontent.com/camrongiuliani/flutter_framework/develop/img/arch-routing.png)

Popping a route is essentially the same, except the application determines which module is currently in use. If it can pop, then the module navigator handles it. If it cannot pop, the module is popped off the navigation stack, exposing the module underneath of it.