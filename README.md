# MatLive SDK Documentation

## Overview
The MatLive SDK provides audio room management capabilities including:
- Room connection management
- Audio track handling
- Seat management
- User management
- Chat messaging
- Event handling

## Installation
Add the SDK dependency to your project.

## Usage

### Initialization
Initialize the SDK in your ViewModel:

    @Published var matliveRoomManager = MatLiveRoomManager.shared

```ios

    let images = [
      "https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp",
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ718nztPNJfCbDJjZG8fOkejBnBAeQw5eAUA&s",
      ]
    var matLiveRoomManger = MatLiveRoomManger.shared

    func initializeRoom(roomId: String, userName:String,appKey:String) async {
    
        await matliveRoomManager.initialize(onInvitedToMic: { seatIndex in
            
        }, onSendGift: { data in
            
        })
        do {
            try await matliveRoomManager.connect(
                name:userName,
                appKey: appKey,
                avatar: images[id],
                userId: "\(Int.random(in: 0..<1000))",
                roomId: roomId,
                metadata: "")
            
            let seatService = matliveRoomManager.seatService
            await seatService?.initWithConfig(config:
                                            MatLiveAudioRoomLayoutConfig(
                                                rowSpacing: 16 ,
                                                rowConfigs: [
                                                    MatLiveAudioRoomLayoutRowConfig(
                                                        count: 4,seatSpacing: 14),
                                                    MatLiveAudioRoomLayoutRowConfig(
                                                        count: 4,seatSpacing: 14),
                                                ]))
        } catch  {
            updateErrorSnackBar(message: error.localizedDescription)
        }
        isLoading = false
      
    }
```

### Seat Management
```kotlin
// Take a seat
    func handleTakeMic(index:Int) async{
        do {
            try await matliveRoomManager.takeSeat(seatIndex: index)
        } catch  {
            print("\(error.localizedDescription)")
        }
    }

// Leave a seat
    func handleLeaveMic(index:Int)  async{
        
        do {
            try await matliveRoomManager.leaveSeat(seatIndex: index)
          
        } catch  {
                print("\(error.localizedDescription)")
        }
    }

// Lock/unlock seats
    func handleLockMic(index:Int)  async{
        do {
            try await matliveRoomManager.lockSeat(seatIndex: index)
        
        } catch  {
            print("\(error.localizedDescription)")
        }
    }
    func handleUnlockMic(index:Int)  async{
        do {
            try await matliveRoomManager.unlockSeat(seatIndex: index)
          
        } catch  {
            print("\(error.localizedDescription)")
        }
    }
```

### Audio Controls
```ios
// Mute/unmute

func handleMuteMic(index:Int)  async {
    
        do {
                try await matliveRoomManager.muteSeat(seatIndex: index)
            }else{
                print("\(error.localizedDescription)")
            }
           
        } catch  {
            updateErrorSnackBar(message: error.localizedDescription)
        }
    }

func handleUnMuteMic(index:Int)  async {
    
        do {
                try await matliveRoomManager.unmuteSeat(seatIndex: index)
            }else{
                print("\(error.localizedDescription)")
            }
           
        } catch  {
            updateErrorSnackBar(message: error.localizedDescription)
        }
    }
```

### Messaging
```ios
    func sendMessage() async {
        try? await matliveRoomManager.sendMessage(textMessage)
        textMessage = ""
    }
```

### Cleanup
```ios

    func closeRoom() async {
        await matliveRoomManager.close()
    }
    
```

## Configuration
Customize the room layout using `MatLiveAudioRoomLayoutConfig`:

```ios
MatLiveAudioRoomLayoutConfig(
    rowSpacing = 16.0,
    rowConfigs = listOf(
        MatLiveAudioRoomLayoutRowConfig(count = 4, seatSpacing = 12),
        MatLiveAudioRoomLayoutRowConfig(count = 4, seatSpacing = 12)
    )
)
```

## Requirements
- iOS 16+
- swift 
