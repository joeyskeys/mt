import AppKit
import MTCore

/// Converts AppKit events to the toolkit-neutral core input contract.
///
/// The native event and view pointers are borrowed. They are only dereferenced
/// during the call and must remain valid for the duration of translation.
/// Translation is main-thread-only because AppKit event and view objects are
/// main-thread-bound.
public final class AppKitInputTranslator {
    private init() {}

    public static func translate(
        nativeEvent: UnsafeMutableRawPointer,
        nativeView: UnsafeMutableRawPointer
    ) -> HostInputEvent? {
        let event = Unmanaged<NSEvent>
            .fromOpaque(nativeEvent)
            .takeUnretainedValue()
        let view = Unmanaged<NSView>
            .fromOpaque(nativeView)
            .takeUnretainedValue()
        let modifiers = modifiers(
            rawValue: UInt64(event.modifierFlags.rawValue)
        )

        switch event.type {
        case .mouseMoved,
             .leftMouseDragged,
             .rightMouseDragged,
             .otherMouseDragged:
            let point = point(event: event, in: view)
            return HostInputEvent(
                kind: .pointerMoved,
                x: point.x,
                y: point.y,
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
        case .leftMouseDown,
             .rightMouseDown,
             .otherMouseDown,
             .leftMouseUp,
             .rightMouseUp,
             .otherMouseUp:
            let point = point(event: event, in: view)
            return HostInputEvent(
                kind: .pointerButton,
                x: point.x,
                y: point.y,
                deltaX: 0,
                deltaY: 0,
                button: Int32(event.buttonNumber),
                pressed: event.type == .leftMouseDown
                    || event.type == .rightMouseDown
                    || event.type == .otherMouseDown,
                keyCode: 0,
                modifiers: modifiers,
                width: 0,
                height: 0,
                focused: false
            )
        case .scrollWheel:
            return HostInputEvent(
                kind: .scroll,
                x: 0,
                y: 0,
                deltaX: event.scrollingDeltaX,
                deltaY: event.scrollingDeltaY,
                button: -1,
                pressed: false,
                keyCode: 0,
                modifiers: modifiers,
                width: 0,
                height: 0,
                focused: false
            )
        case .keyDown, .keyUp:
            return HostInputEvent(
                kind: .key,
                x: 0,
                y: 0,
                deltaX: 0,
                deltaY: 0,
                button: -1,
                pressed: event.type == .keyDown,
                keyCode: UInt32(event.keyCode),
                modifiers: modifiers,
                width: 0,
                height: 0,
                focused: false
            )
        default:
            return nil
        }
    }

    public static func modifiers(rawValue: UInt64) -> InputModifiers {
        let flags = NSEvent.ModifierFlags(rawValue: UInt(rawValue))
        return InputModifiers(
            shift: flags.contains(.shift),
            control: flags.contains(.control),
            option: flags.contains(.option),
            command: flags.contains(.command),
            capsLock: flags.contains(.capsLock)
        )
    }

    public static func resize(width: UInt32, height: UInt32) -> HostInputEvent {
        HostInputEvent.resize(width: width, height: height)
    }

    public static func close() -> HostInputEvent {
        HostInputEvent.close()
    }

    public static func focus(_ focused: Bool) -> HostInputEvent {
        HostInputEvent.focus(focused)
    }

    private static func point(
        event: NSEvent,
        in view: NSView
    ) -> (x: Double, y: Double) {
        let localPoint = view.convert(event.locationInWindow, from: nil)
        return (
            Double(localPoint.x - view.bounds.minX),
            Double(view.bounds.maxY - localPoint.y)
        )
    }
}
