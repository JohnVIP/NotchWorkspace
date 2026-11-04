// SPDX-License-Identifier: MIT
import AudioToolbox
import CoreAudio
import NotchCore

/// The output device's volume and mute.
public struct VolumeState: Equatable, Sendable {
    /// 0...1.
    public var level: Float
    public var muted: Bool

    public init(level: Float, muted: Bool) {
        self.level = level
        self.muted = muted
    }
}

/// Raises a live activity when the output volume or mute changes. Core Audio calls back on changes,
/// and switching output devices moves the listener along without announcing.
@MainActor
public final class VolumeMonitor {
    public var onActivity: ((Activity) -> Void)?
    public private(set) var isRunning = false

    private var device = AudioObjectID(kAudioObjectUnknown)
    private var last: VolumeState?
    private var deviceListener: AudioObjectPropertyListenerBlock?
    private var valueListener: AudioObjectPropertyListenerBlock?

    public init() {}

    public func start() {
        guard !isRunning else { return }
        isRunning = true
        let listener: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
            MainActor.assumeIsolated { self?.follow(Self.defaultOutput()) }
        }
        var address = Self.defaultOutputAddress
        if AudioObjectAddPropertyListenerBlock(Self.system, &address, .main, listener) == noErr {
            deviceListener = listener
        }
        follow(Self.defaultOutput())
    }

    public func stop() {
        guard isRunning else { return }
        isRunning = false
        follow(AudioObjectID(kAudioObjectUnknown))
        if let deviceListener {
            var address = Self.defaultOutputAddress
            AudioObjectRemovePropertyListenerBlock(Self.system, &address, .main, deviceListener)
        }
        deviceListener = nil
    }

    /// What the notch shows for a volume: a speaker with as many waves as the level, the percentage,
    /// and a meter.
    nonisolated static func activity(for state: VolumeState) -> Activity {
        let level = state.muted ? 0 : Double(state.level)
        let symbol =
            switch level {
            case ..<0.005: "speaker.slash.fill"
            case ..<0.34: "speaker.wave.1.fill"
            case ..<0.67: "speaker.wave.2.fill"
            default: "speaker.wave.3.fill"
            }
        let title = state.muted ? "Muted" : "\(Int((level * 100).rounded()))%"
        return Activity(feature: nil, symbol: symbol, title: title, level: level, duration: .milliseconds(1500))
    }

    // MARK: Core Audio

    private static let system = AudioObjectID(kAudioObjectSystemObject)

    private static func address(
        _ selector: AudioObjectPropertySelector, scope: AudioObjectPropertyScope = kAudioDevicePropertyScopeOutput
    ) -> AudioObjectPropertyAddress {
        AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: kAudioObjectPropertyElementMain)
    }

    private static let volumeSelector = kAudioHardwareServiceDeviceProperty_VirtualMainVolume
    private static let defaultOutputAddress = address(
        kAudioHardwarePropertyDefaultOutputDevice, scope: kAudioObjectPropertyScopeGlobal)

    private static func defaultOutput() -> AudioObjectID {
        var address = defaultOutputAddress
        var device = AudioObjectID(kAudioObjectUnknown)
        var size = UInt32(MemoryLayout<AudioObjectID>.size)
        AudioObjectGetPropertyData(system, &address, 0, nil, &size, &device)
        return device
    }

    /// Moves the listener to `device` and takes its current state quietly: a new device's volume
    /// isn't a change the user made.
    private func follow(_ device: AudioObjectID) {
        if let valueListener, self.device != kAudioObjectUnknown {
            for selector in [Self.volumeSelector, kAudioDevicePropertyMute] {
                var address = Self.address(selector)
                AudioObjectRemovePropertyListenerBlock(self.device, &address, .main, valueListener)
            }
        }
        valueListener = nil
        self.device = device
        last = read()
        guard device != kAudioObjectUnknown else { return }
        let listener: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
            MainActor.assumeIsolated { self?.changed() }
        }
        for selector in [Self.volumeSelector, kAudioDevicePropertyMute] {
            var address = Self.address(selector)
            if AudioObjectHasProperty(device, &address) {
                AudioObjectAddPropertyListenerBlock(device, &address, .main, listener)
            }
        }
        valueListener = listener
    }

    private func changed() {
        guard let state = read(), state != last else { return }
        last = state
        onActivity?(Self.activity(for: state))
    }

    private func read() -> VolumeState? {
        var address = Self.address(Self.volumeSelector)
        guard device != kAudioObjectUnknown, AudioObjectHasProperty(device, &address) else { return nil }
        var level: Float32 = 0
        var size = UInt32(MemoryLayout<Float32>.size)
        guard AudioObjectGetPropertyData(device, &address, 0, nil, &size, &level) == noErr else { return nil }
        var mute = Self.address(kAudioDevicePropertyMute)
        var muted: UInt32 = 0
        size = UInt32(MemoryLayout<UInt32>.size)
        if AudioObjectHasProperty(device, &mute) { AudioObjectGetPropertyData(device, &mute, 0, nil, &size, &muted) }
        return VolumeState(level: level, muted: muted != 0)
    }
}
