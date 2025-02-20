local AnimationUtil = {}

function AnimationUtil.LoadAnimationTrack(character: Model, animationID: string): AnimationTrack
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        warn("No Humanoid found in character")
        return nil
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = animationID

    local track = animator:LoadAnimation(animation)
    animation:Destroy()
    return track
end

function AnimationUtil.CreateAnimationTracks(character: Model, animationIDs: {[string]: string}): {[string]: AnimationTrack}
    local animationTracks = {}
    for name, id in pairs(animationIDs) do
        local track = AnimationUtil.LoadAnimationTrack(character, id)
        if track then
            animationTracks[name] = track
        end
    end
    return animationTracks
end

function AnimationUtil.PlayTrackForDuration(animationTrack: AnimationTrack, duration: number)
    if not animationTrack or not animationTrack:IsA("AnimationTrack") then
        warn("Invalid AnimationTrack provided.")
        return
    end

    local animationLength = animationTrack.Length
    if animationLength <= 0 then
        warn("Animation length is invalid or zero.")
        return
    end

    local playbackSpeed = animationLength / duration
    animationTrack:Play()
    animationTrack:AdjustSpeed(playbackSpeed)
end

return AnimationUtil
