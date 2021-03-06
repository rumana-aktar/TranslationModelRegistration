% CHIRPLIN   Generates linear chirp test image
%
% The test image consists of a linear chirp signal in the horizontal direction
% with the amplitude of the chirp being modulated from 1 at the top of the image
% to 0 at the bottom.
%
% Usage: im = chirplin(sze, f0, k, p)
%
% Arguments:     sze - [rows cols] specifying size of test image.  If a
%                      single value is supplied the image is square.
%                 f0 - Initial frequency.
%                  k - Rate at which frequency increases (try 0.001).
%                  p - Power to which the linear attenuation of amplitude, 
%                      from top to bottom, is raised.  For no attenuation use
%                      p = 0. For contrast sensitivity experiments use larger
%                      values of p.  The default value is 4.
%
% Example:  im = chirplin(500, 0, .001, 4)
%
% I have used this test image to evaluate the effectiveness of different
% colourmaps, and sections of colourmaps, over varying spatial frequencies and
% contrast.
%
% See also: CHIRPEXP

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% 
% March 2012

function im = chirplin(sze, f0, k, p)
    
    if length(sze) == 1
        rows = sze; cols = sze;
    elseif length(sze) == 2
        rows = sze(1); cols = sze(2);
    else
        error('size must be a 1 or 2 element vector');
    end
    
    if ~exist('p', 'var'), p = 4; end
            
    x = 0:cols-1;
    fx = sin((f0 + k/2*x).*x);
    
    A = ([(rows-1):-1:0]/(rows-1)).^p;
    im = A'*fx;