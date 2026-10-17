import Foundation

public enum InputEventKind: Int32 {
    case pointerMoved
    case pointerButton
    case scroll
    case key
    case resize
    case close
    case focus
}

public struct InputModifiers {
    public var shift: Bool
    public var control: Bool
    public var option: Bool
    public var command: Bool
    public var capsLock: Bool

    public init(
        shift: Bool,
        control: Bool,
        option: Bool,
        command: Bool,
        capsLock: Bool
    ) {
        self.shift = shift
        self.control = control
        self.option = option
        self.command = command
        self.capsLock = capsLock
    }

    public static func none() -> InputModifiers {
        InputModifiers(
            shift: false,
            control: false,
            option: false,
            command: false,
            capsLock: false
        )
    }
}

public struct HostInputEvent {
    public var kind: InputEventKind
    public var x: Double
    public var y: Double
    public var deltaX: Double
    public var deltaY: Double
    public var button: Int32
    public var pressed: Bool
    public var keyCode: UInt32
    public var modifiers: InputModifiers
    public var width: UInt32
    public var height: UInt32
    public var focused: Bool

    public init(
        kind: InputEventKind,
        x: Double,
        y: Double,
        deltaX: Double,
        deltaY: Double,
        button: Int32,
        pressed: Bool,
        keyCode: UInt32,
        modifiers: InputModifiers,
        width: UInt32,
        height: UInt32,
        focused: Bool
    ) {
        self.kind = kind
        self.x = x
        self.y = y
        self.deltaX = deltaX
        self.deltaY = deltaY
        self.button = button
        self.pressed = pressed
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.width = width
        self.height = height
        self.focused = focused
    }

    public static func pointerMoved(
        x: Double,
        y: Double,
        modifiers: InputModifiers
    ) -> HostInputEvent {
        HostInputEvent(
            kind: .pointerMoved,
            x: x,
            y: y,
            deltaX: 0,
            deltaY: 0,
            button: -1,
            pressed: false,
            keyCode: 0,
            modifiers: modifiers,
            width: 0,
            height: 0,
            focused: false
        )
    }

    public static func scroll(
        deltaX: Double,
        deltaY: Double,
        modifiers: InputModifiers
    ) -> HostInputEvent {
        HostInputEvent(
            kind: .scroll,
            x: 0,
            y: 0,
            deltaX: deltaX,
            deltaY: deltaY,
            button: -1,
            pressed: false,
            keyCode: 0,
            modifiers: modifiers,
            width: 0,
            height: 0,
            focused: false
        )
    }

    public static func resize(width: UInt32, height: UInt32) -> HostInputEvent {
        HostInputEvent(
            kind: .resize,
            x: 0,
            y: 0,
            deltaX: 0,
            deltaY: 0,
            button: -1,
            pressed: false,
            keyCode: 0,
            modifiers: InputModifiers.none(),
            width: width,
            height: height,
            focused: false
        )
    }

    public static func close() -> HostInputEvent {
        HostInputEvent(
            kind: .close,
            x: 0,
            y: 0,
            deltaX: 0,
            deltaY: 0,
            button: -1,
            pressed: false,
            keyCode: 0,
            modifiers: InputModifiers.none(),
            width: 0,
            height: 0,
            focused: false
        )
    }

    public static func focus(_ focused: Bool) -> HostInputEvent {
        HostInputEvent(
            kind: .focus,
            x: 0,
            y: 0,
            deltaX: 0,
            deltaY: 0,
            button: -1,
            pressed: false,
            keyCode: 0,
            modifiers: InputModifiers.none(),
            width: 0,
            height: 0,
            focused: focused
        )
    }
}

