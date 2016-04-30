title=Petit Workout - The Application
date=2016-04-19
type=post
category=code
tags=Java, JavaFX, Application, Petit Workout
status=published
~~~~~~


Hello again! Today we're going to continue working on the little workout application we instigated in my previous blog post. This post will cover the basic concepts behind generating a _Graphical User Interface_ for a Java application :coffee:


### JavaFX || Swing || AWT

`Swing`, `JavaFX` and `AWT` are GUI widget toolkits that offer components to allow the interaction between users and applications. Right away we can eliminate `AWT` from our potential application toolkit as it directly uses the operating system's components; meaning that the resulting application will not have the same _look and feel_ on Ubuntu, Mac and Windows. This leaves us with `Swing` and `JavaFX` as candidates. Both are valid for our needs, however, Oracle corp. has determined that `JavaFX` is set to be replacing `Swing` as *the* GUI toolkit. This means that it isn't deprecated as of yet, but is receiving far less attention in the latest Java releases.


### JavaFX Basics

Here is a simple visual representation of how a basic JavaFX application is structured:


	 _____________________
	| stage             x |
	|  _________________  |
	| | scene           | |
	| |  _____________  | |
	| | | layout pane | | |
	| | |  _________  | | |
	| | | | button  | | | |



So we need to add components (buttons, labels, graphics, etc.) to a layout, that is set within a scene, that is held within a stage.

In code, it looks like this:


	import javafx.application.Application;
	import javafx.scene.Scene;
	import javafx.scene.control.Button;
	import javafx.scene.layout.StackPane;
	import javafx.stage.Stage;

	public class WorkoutQueueTest extends Application {

	    private Label timerLabel;

	    public static void main(String[] args) throws Exception
	    {
	        launch(args);
	    }

	    @Override
	    public void start(Stage primaryStage) throws Exception
	    {
	        primaryStage.setTitle("Petit Workout");

	        Button startBtn  = new Button("Start");
	        startBtn.setOnAction((e) -> startWorkout());

	        timerLabel = new Label("00:00:00");

	        BorderPane pane  = new BorderPane();
	        pane.setTop(startBtn);
	        pane.setBottom(timerLabel);
	        primaryStage.setScene(new Scene(pane, 300, 250));

	        // @todo add terminate thread on close
	        primaryStage.show();
	    }

	    public void startWorkout()
	    {
	        AnimationTimer animationTimer = new AnimationTimer() {
	        	long startTime = System.nanoTime();

	            @Override
	            public void handle(long now) {
	                timerLabel.setText(
	                    ReadableTimeConverter.convert(
	                        toIntExact(
	                        	(now - startTime) / 1000000000
	                        )
	                    )
	                );
	            }
	        };

	        animationTimer.start();
	    }
	}


### Labels and Buttons

Components classes offer more than one constructor, meaning that the argument count will determine what funtion is called. For example:

	Label timerLabel = new Label();
	timerLabel.setText("00:00:00");

Is the same as:

	Label timerLabel = new Label("00:00:00");

This is because Java supports classes with multiple constructors, which means that the constructor being called is determined by its signature. This is called *overloading constructers*. If we dig a bit deeper, we can see that the `Label` class offers three different constructors:

	/**
     * Creates an empty label
     */
    public Label() {
        initialize();
    }

    /**
     * Creates Label with supplied text.
     * @param text null text is treated as the empty string
     */
    public Label(String text) {
        super(text);
        initialize();
    }

    /**
     * Creates a Label with the supplied text and graphic.
     * @param text null text is treated as the empty string
     * @param graphic a null graphic is acceptable
     */
    public Label(String text, Node graphic) {
        super(text, graphic);
        initialize();
    }


This means that an often used actions such as adding text and graphics to a newly created `Label` and `Button` objects are accessible through a one-liner method call.

#### Buttons and Lambda Event Handling

Specific to buttons is the possibility to generate event listeners whose methods execute logic based on events and targets. In our case, we want to call upon the `startWorkout` method upon button click.

From the Java doc:

> When a button is pressed and released a ActionEvent is sent. Your application can perform some action based on this event by implementing an EventHandler to process the ActionEvent.

And:

> Lambda Expressions enable you to encapsulate a single unit of behavior and pass it to other code. You can use a lambda expressions if you want a certain action performed on each element of a collection, when a process is completed, or when a process encounters an error.


Starting Java 8, you can use anonynous (lambda) functions in your code:

	startBtn.setOnAction((e) -> startWorkout());

This is a much more direct, easy-to-read and elegant way to execute the following:

	startBtn.setOnAction(new EventHandler<ActionEvent>() {
		@Override
		public void handle(ActionEvent event) {
			startWorkout();
		}
	});

So there's really no excuse in our case to not opt for the Lambda expression; the resulting smaller code footprint and _straight-to-the-point_ syntax really improve legibility.


### Layout Panes

Once we've created our buttons and labels, we need to place these on the application window. This is where the JavaFX SDK's layout container classes, such as `BorderPane`, `StackPane`, `GridPane` and `FlowPane`, come to our aid. You can manually lay out UI components by setting their position and size within your JavaFX application. However, using layouts makes it easier - and quicker - to manage the classic cases where you need such common layouts as rows, columns and tiles. It even covers repositioning elements upon window resize operations. Since *Petit Workout*, in its current iteration, is quite *humble*, we can use the basic `BorderPane` layout container, which looks like this:

	 _______________________
	| top                   |
	|_______________________|
	| left | center | right |
	|______|________|_______|
	| bottom                |
	|_______________________|


Placing our elements is then as easy as	using the `set` methods available with the `BorderPane`:

	BorderPane pane = new BorderPane();
    pane.setTop(startBtn);
    pane.setBottom(timerLabel);


### Scene and Stage -- Or putting it all together

	primaryStage.setScene(new Scene(pane, 300, 250));
    primaryStage.show();


### Timer

Since we want to be as conservative as possible with thread usage in order to save resources, we can latch on to pre-existing runnable implementations to run a timer that monitors our workout. We can thus instantiate a new `AnimationTimer` that is associated to the JavaFX `MasterTimer` instance. In effect, this means that our `AnimationTimer` events will fire upon ever frame within our JavaFX application, much like the Swing `redraw` method.


	long timestampOnInit = System.nanoTime();
    AnimationTimer animationTimer = new AnimationTimer() {
        @Override
        public void handle(long now) {
            timerLabel.setText(
                ReadableTimeConverter.convert(
                    toIntExact((now - timestampOnInit) / 1000000000)
                )
            );
        }
    };


In effect, upon each frame execution, compare the current timestamp with the one we captured upon *start* button press. The resultant timestamp is afterward used to update our application's timer label with the elapsed time value converter as a `ReadableTimeConverter` value:


	public class ReadableTimeConverter {

	    /**
	     * @param seconds
	     * @return String
	     */
	    public static String convert(int seconds)
	    {
	        int hr  = seconds / 3600;
	        int rem = seconds % 3600;
	        int mn  = rem / 60;
	        int sec = rem % 60;

	        return (hr < 10 ? "0" : "") + hr + ":" + (mn < 10 ? "0" : "") + mn + ":" + (sec < 10 ? "0" : "") + sec;
	    }
	}


The advantage with this solution is that we are never dependent upon the CPU cycle's *idea* of a timestamp. If we were to instantiate a `runnable` instance set to execute, for example, every second, after some time we would start to see pretty severe discrepencies between our application's time and real time. This is because scheduled `runnable` tasks are dependent upon the CPU cycle's time. This can manifest in slower or faster times. So you could be, without knowing it, working out for a mear 40 minutes instead of a full 45; which is _unacceptable_ ;)


### Closing Statement

So this brings us a little closer to a fully working workout application. In the next blog post we'll integrate our `producer-consumer` thread pattern and add a countdown and intensity label to the GUI :excited:

> As always, the code related to this blog post is available on my [GitHub account](https://github.com/apricat/petitworkout).