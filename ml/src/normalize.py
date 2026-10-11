"""Stage 2-4 - Normalize, map labels, and clean.

Turns every dataset into a common record
    {image, label, category, source, origin}
and removes corrupt, undersized, and near-duplicate (perceptual hash) images.

Status: scaffold. Implementation pending pipeline decisions.
"""
