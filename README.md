# NovaliaBLE

## Building a NovaliaBLE based app for iOS

To run the example project, clone the repo, and run `pod install` from the Example directory first

Create a new Universal Swift application in Xcode.

Close the project in Xcode.

## Pod Installation

Ensure you have [CocoaPods](http://cocoapods.org) installed.

In Terminal, go to the project directory and run:

```
pod init
```

Edit `Podfile` and add the following line to the target section:

```ruby
pod 'NovaliaBLE', :git => 'https://github.com/novalia/NovaliaBLE.git'
```

Ensure the `use_frameworks!` line is uncommented so it works with Swift.

Uncomment the `platform` line and set the required iOS version.

Run:

```
pod install
```

Use the Xcode workspace instead of the project file from now on.

```
open App.xcworkspace
```

## Adding to ViewController

The minimum setup requires the following code added to the ViewController:

```
import NovaliaBLE
```

Add the delegate protocols to the class:

```
NovaliaBLEInterfaceDelegate, NovaliaBLEDeviceEventDelegate
```

Add the following vars to the class:

```
// NovaliaBLEInterface vars
var interface: NovaliaBLEInterface!
var previousBLEState: NovaliaBLEState!
var launchDiscoveryTimer: NSTimer!
var selectedDevices = [NovaliaBLEDevice]()
var currentDevice: NovaliaBLEDevice!
```

### NovaliaBLEInterface methods

```
// MARK: NovaliaBLEInterface methods
    func initInterfaceIfNeeded() {

        if(interface == nil) {
            interface = NovaliaBLEInterface(delegate: self)
            previousBLEState = BLEStateNotReady
            launchDiscoveryTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(startDiscovery), userInfo: nil, repeats: false)
        }
    }

    func startDiscovery() {

        launchDiscoveryTimer = NSTimer.scheduledTimerWithTimeInterval(30.0, target: self, selector: #selector(stopDiscovery), userInfo: nil, repeats: false)

        if currentDevice == nil {
            // Set a status message to indicate no device connected
        }

        // Set the device name to be searched for e.g. novppia1
        // Setting the device name to * searches for all devices
        self.interface.startDeviceDiscovery("novppia1")
    }

    func stopDiscovery() {

        if currentDevice == nil {
            // Set a status message to indicate no device connected
        }

        launchDiscoveryTimer = nil
        self.interface.stopDeviceDiscovery()
    }

```

### NovaliaBLEInterface Delegate methods


```
// MARK: NovaliaBLEInterface Delegate methods
    func onDeviceDiscovered(device: NovaliaBLEDevice!) {

        print("Device discovered")
        if currentDevice == nil {
            // Set a status message to indicate connecting to device
        }

        var array = selectedDevices
        let index = array.indexOf(device)

        if(index != nil) {
            array[index!] = device
        } else {
            array.append(device)
        }

        device.delegate = self
        selectedDevices = array
        interface.connectToDevice(device)
    }

    func onDeviceListChanged(newList: [AnyObject]!) {

        var connected = 0
        var connecting = 0
        var disconnected = 0

        for device: NovaliaBLEDevice in newList as! [NovaliaBLEDevice] {
            if(isDeviceConnected(device)) {
                print("\(device.uuid.UUIDString) connected")
                connected += 1
            } else if(isDeviceConnecting(device)) {
                print("\(device.uuid.UUIDString) connecting")
                connecting += 1
            } else if(isDeviceDisconnected(device)) {
                print("\(device.uuid.UUIDString) disconnected")
                disconnected += 1
            }
        }

        // This is where an indicator of how many devices are connected, connecting, disconnected should be displayed
        print(String(format:"Connected %d Connecting %d Disconnected %d", connected, connecting, disconnected))

        let isConnecting = (connecting > 0)

        if(isConnecting) {
            // Start any connecting animation
        } else {
            // Stop any connecting animation
        }
    }

    func onDeviceConnected(device: NovaliaBLEDevice!) {
        // Set a status message to indicate device connected

        if(device.deviceName == "novppia1") {
            currentDevice = device
            if(isDeviceConnected(currentDevice)) {
                print("\(currentDevice.uuid.UUIDString) connected")
            } else if(isDeviceConnecting(currentDevice)) {
                print("\(currentDevice.uuid.UUIDString) connecting")
            } else if(isDeviceDisconnected(currentDevice)) {
                print("\(currentDevice.uuid.UUIDString) disconnected")
            }
        } else {
            print("\(device.deviceName) is not what we are looking for")
        }
    }

    func isDeviceConnected(device: NovaliaBLEDevice) -> Bool {
        return (device.status & NovaliaBLEDeviceConnected) == NovaliaBLEDeviceConnected
    }
    func isDeviceConnecting(device: NovaliaBLEDevice) -> Bool {
        return (device.status & NovaliaBLEDeviceConnecting) == NovaliaBLEDeviceConnecting
    }
    func isDeviceDisconnected(device: NovaliaBLEDevice) -> Bool {
        return isDeviceConnected(device) == false && isDeviceConnecting(device) == false
    }



    func onDeviceDisconnected(device: NovaliaBLEDevice!) {
        currentDevice = nil

        // Set a status message to indicate no device connected

        // Try to reconnect
        interface.connectToDevice(device)
    }


    func onBLEStateChanged(state: NovaliaBLEState) {

        if(previousBLEState == state) {
            return
        }

        previousBLEState = state

        var title = ""
        var message = ""

        switch state.rawValue {
        case BLEStateOff.rawValue:
            title = "Bluettoth Power"
            message = "You must turn on Bluetooth in Settings in order to use this application"
        case BLEStateUnsupported.rawValue:
            title = "Bluetooth Unsupported"
            message = "Your device does not seem to be compatible with Bluetooth Low Energy standard."
        case BLEStateNotReady.rawValue:
            title = "Bluetooth Not Ready"
            message = "Bluetooth service on your device does not seem to be ready. It may be initialising or restarting."
        default: ()
        }

        if(!title.isEmpty) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func onButtonPressed(button: Int32, velocity: Int32, onDevice device: AnyObject!) {
        print("Button pressed \(button) on device \(device.UUIDString)")

        // Now do something in response to a button being pressed
    }

```

### Initalising the interface

Add the following to `viewDidLoad`:

```
initInterfaceIfNeeded()
```
