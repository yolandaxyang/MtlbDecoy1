%normalized x ranges from 1 to 11
%u ranges from 0 to 1
global Attribute1Bounds Attribute2Bounds AttributeSpan
NormalizeU = @(u) 10 * u + [1,1];
DenormalizeU = @(x_norm) (x_norm - [1,1]) / 10; %Returns a normalized [xi1 xi2]
UtoX= @(u) [Attribute1Bounds(1) Attribute2Bounds(1)] + u .* AttributeSpan;
XtoU = @(x) (x - [Attribute1Bounds(1) Attribute2Bounds(1)]) ./ AttributeSpan;
NormalizeX = @(x) NormalizeU(XtoU(x)) ;
DenormalizeX = @(x_norm) UtoX(DenormalizeU(x_norm));