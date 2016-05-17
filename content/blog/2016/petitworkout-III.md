title=Petit Workout - The Application
date=2016-05-08
type=post
category=code
tags=Java, JavaFX, Application, Petit Workout
status=published
~~~~~~

![Working out](images/SpriteSheet.png ":]")

Our petit workout application is finally taking shape! We can now start our workouts and see the elapsed time... which means that all we have currently is no better than a timer!

In this article, we'll enhance the application with a way to visualize the interval's intensity, the remaining time for the current interval, and we'll add a little sprite animation for some visual appeal.


### Main Class

	public class WorkoutQueueTest extends Application {

	    private Label timerLabel     = new Label("00:00:00");
	    private Label countdownLabel = new Label("00:00:00");
	    private Label intensityLabel = new Label("Easy");

	    private Sprite spriteAnimation;

	    public static void main(String[] args) throws Exception
	    {
	        launch(args);
	    }

	    @Override
	    public void start(Stage primaryStage) throws Exception
	    {
	        primaryStage.setTitle("Petit Workout");

	        final ImageView imageView = new ImageView(
	            new Image("file:" + this.getClass().getResource("/SpriteSheet.png").getPath())
	        );
	        imageView.setViewport(new Rectangle2D(0, 68, 64, 64));

	        spriteAnimation = new Sprite(imageView, 4, 4, 0, 68, 64, 64);
        	spriteAnimation.setCycles(Duration.millis(1000));

	        final Button startBtn = new Button("Start");
	        startBtn.setOnAction((e) -> startWorkout());

	        BorderPane pane = new BorderPane();

	        pane.setTop(startBtn);
	        pane.setBottom(timerLabel);
	        pane.setRight(countdownLabel);

	        StackPane centerPane = new StackPane();
	        centerPane.getChildren().addAll(intensityLabel, imageView);

	        pane.setCenter(centerPane);

	        primaryStage.setScene(new Scene(pane, 300, 250));

	        primaryStage.show();
	    }

	    public void startWorkout()
	    {
	        Queue queue = new Queue();

	        spriteAnimation.play();

	        (new EventsPerFrame(queue, timerLabel, countdownLabel, intensityLabel)).start();

	        Producer producer = new Producer(queue);
	        new Thread(producer).start();

	        Consumer consumer = new Consumer(queue);
	        new Thread(consumer).start();
	    }
	}


As you can see, a few things were added to the main classe's `start` method. The `ImageView` loads our sprite sheet image, and the `SpriteAnimation` class handles animating it. We also added label elements, which are updated on every frame using the `EventsPerFrame` method that extends the `javafx.animation.AnimationTimer` class.


### Labels


	private Label timerLabel     = new Label("00:00:00");
    private Label countdownLabel = new Label("00:00:00");
    private Label intensityLabel = new Label("Easy");


The main class is then only in charge of _placing_ the elements within the application window:


	final Button startBtn = new Button("Start");
    startBtn.setOnAction((e) -> startWorkout());

    BorderPane pane = new BorderPane();

    pane.setTop(startBtn);
    pane.setBottom(timerLabel);
    pane.setRight(countdownLabel);

    StackPane centerPane = new StackPane();
    centerPane.getChildren().addAll(intensityLabel, imageView);

    pane.setCenter(centerPane);


Note that the `intensityLabel` shares a `BorderPane` pane with the `imageView` object. Using the `StackPane` layout, or any other layouts, we can easily add multiple elements unto a single pane.

In the previous blog post, we used the `AnimationTimer` method to fire events on each frame. To better handle the extra logic behind our extra labels, the `EventsPerFrame` method was created to extend on the `AnimationTimer` and handle the labels' state on every frame change.

	(new EventsPerFrame(queue, timerLabel, countdownLabel, intensityLabel)).start();


Now let's look at the class in detail:

	public class EventsPerFrame extends javafx.animation.AnimationTimer
	{
	    long startTime = System.nanoTime();
	    int stopwatch  = 0;
	    Interval intervalInProgress;

	    private Queue queue;
	    private Label timerLabel;
	    private Label countdownLabel;
	    private Label intensityLabel;

	    public EventsPerFrame(
            Queue queue,
            Label timerLabel,
            Label countdownLabel,
            Label intensityLabel
	    ) {
	        this.queue          = queue;
	        this.timerLabel     = timerLabel;
	        this.countdownLabel = countdownLabel;
	        this.intensityLabel = intensityLabel;
	    }

	    @Override
	    public void handle(long now)
	    {
	        Interval interval;
	        try {
	            interval = queue.element();
	        } catch (java.lang.NullPointerException e) {
	            return;
	        }

	        if (interval == null) {
	            return;
	        }

	        int elapsedTime = toIntExact((now - startTime) / 1000000000);

	        timerLabel.setText(ReadableTimeConverter.convert(elapsedTime));
	        countdownLabel.setText(ReadableTimeConverter.convert(stopwatch - elapsedTime));
	        intensityLabel.setText(interval.getIntensity());

	        if (intervalStillInProgress(interval)) {
	            return;
	        }

	        intervalInProgress = interval;
	        stopwatch          = toIntExact(elapsedTime + interval.getDuration());
	    }

	    private boolean intervalStillInProgress(Interval interval) {
	        return intervalInProgress == interval;
	    }
	}

	public class ReadableTimeConverter {

	    /**
	     * @param seconds
	     * @return String
	     */
	    public static String convert(int seconds)
	    {
	        int hr = seconds / 3600;
	        int rem = seconds % 3600;
	        int mn = rem / 60;
	        int sec = rem % 60;

	        return (hr < 10 ? "0" : "") + hr + ":" + (mn < 10 ? "0" : "") + mn + ":" + (sec < 10 ? "0" : "") + sec;
	    }
	}


It may look complicated, but its quite simple; we always increment the `elapsedTime`, always decrement the `stowatch`, and always update the `intensityLabel` with the value we get from the current `Interval` object being processed. The only complicated bit is that we need to "refill" the stopwatch with the interval's duration whenever we detect that the queue has picked up a new interval.


### ImageView

Now back on the main class, we added an `ImageView`, which is sent to a `Sprite` class.

From the Java documentation:

> "The ImageView is a Node used for painting images loaded with Image class."

In other words, the Image view, using the `setViewport` method, permits the "clipping" of an image, i.e. removing and adding pixels to an image's "visible area"

	final ImageView imageView = new ImageView(
        new Image("file:" + this.getClass().getResource("/SpriteSheet.png").getPath())
    );
	imageView.setViewport(new Rectangle2D(0, 68, 64, 64));
	spriteAnimation = new Sprite(imageView, 4, 4, 0, 68, 64, 64);

> Note that since the image is a local resource file, we append `file:` to the path.

The `Sprite` class is where the animation happens. Simply put, our viewport has a set width and height, that "frames" our `SpriteSheet`. On every new frame animation we `move` the `SpriteSheet` horizontally and this, until we reach the end of the `SpriteSheet` where we start again. This is the same concept used with traditional film, so the logic is quite simple to grasp.


	public class Sprite extends Transition {

	    private final ImageView imageView;
	    private final int frameCount;
	    private final int columns;
	    private final int offsetX;
	    private final int offsetY;
	    private final int width;
	    private final int height;

	    private int lastIndex;

	    public Sprite(
	        ImageView imageView,
	        int frameCount,
	        int columns,
	        int offsetX,
	        int offsetY,
	        int width,
	        int height
	    ) {
	        this.imageView  = imageView;
	        this.frameCount = frameCount;
	        this.columns    = columns;
	        this.offsetX    = offsetX;
	        this.offsetY    = offsetY;
	        this.width      = width;
	        this.height     = height;
	    }

	    public void setCycles(Duration duration)
	    {
	        setCycleDuration(duration);
	        setInterpolator(Interpolator.LINEAR);
	        setCycleCount(INDEFINITE);
	    }

	    protected void interpolate(double k) {
	        final int index = Math.min((int) Math.floor(k * frameCount), frameCount - 1);
	        if (index != lastIndex) {
	            final int x = (index % columns) * width  + offsetX;
	            final int y = (index / columns) * height + offsetY;
	            imageView.setViewport(new Rectangle2D(x, y, width, height));
	            lastIndex = index;
	        }
	    }
	}

And that's it! So now, we can *start* our workout series, display the *intensity* for the current interval, as well as its *remaining time*, and, lastly, display a little sprite animation to go along with the application. In the next article, we will cover how to implement multiple workouts as `json` structured application resources.

> As always, the code related to this blog post is available on my [GitHub account](https://github.com/apricat/petitworkout).