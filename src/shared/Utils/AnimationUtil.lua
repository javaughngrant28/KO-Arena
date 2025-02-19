local AnimationUtil = {}

function AnimationUtil.CreateAnimationTracks(character: Model, animationIDs: {[string]: string}): {[string]: AnimationTrack}
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        warn("No Humanoid found in character")
        return {}
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    local animationTracks = {}

    for name, id in pairs(animationIDs) do
        local animation = Instance.new("Animation")
        animation.AnimationId = id

        local track = animator:LoadAnimation(animation)
        animationTracks[name] = track
    end

    return animationTracks
end

return AnimationUtil
