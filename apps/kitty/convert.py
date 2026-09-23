h = input("hex without #")
print(
    "float3(%.3f, %.3f, %.3f)"
    % tuple(
        ((c / 255 + 0.055) / 1.055) ** 2.4 if c / 255 > 0.04045 else c / 255 / 12.92
        for c in bytes.fromhex(h)
    )
)
