
local mt = {
	setOffsets = function(x,y)
		self.offsetX=x
		self.offsetY=y
	end,
	
	process = function(self, x,y)
			mat = self.warpmatrix;
			
			a = (x * mat[1] + y*mat[5] + mat[13]);
				b = (x * mat[2] + y*mat[6] + mat[14]);
				c = (x * mat[4] + y*mat[8] + mat[16]);  
				return a/c, b/c;
				
		  
	end,
    setsrc = function(self, dot1,dot2,dot3,dot4)
        
        self.srcdots = {{tonumber(dot1[1]),tonumber(dot1[2])},{tonumber(dot2[1]),tonumber(dot2[2])},{tonumber(dot3[1]),tonumber(dot3[2])},{tonumber(dot4[1]),tonumber(dot4[2])}};
        
        self:computeWarpMatrix();
    end,
        
    setdst = function(self,dot1,dot2,dot3,dot4)
        self.dstdots = {{tonumber(dot1[1]),tonumber(dot1[2])},{tonumber(dot2[1]),tonumber(dot2[2])},{tonumber(dot3[1]),tonumber(dot3[2])},{tonumber(dot4[1]),tonumber(dot4[2])}};
        self:computeWarpMatrix();
    end,
        
    computeWarpMatrix = function(self)
        self.srcmatrix = self:computeQuadToSquare(self.srcdots);
        self.dstmatrix = self:computeSquareToQuad(self.dstdots);
        self.warpmatrix = self:multMats(self.srcmatrix,self.dstmatrix);
    end,
        
    computeSquareToQuad = function(self, inputdots)
        local x0 = inputdots[1][1]
        local y0 = inputdots[1][2]
        local x1 = inputdots[2][1]
        local y1 = inputdots[2][2]
        local x2 = inputdots[3][1]
        local y2 = inputdots[3][2]
        local x3 = inputdots[4][1]
        local y3 = inputdots[4][2]
        local dx1 = x1 - x2
        local dy1 = y1 - y2
        local dx2 = x3 - x2
        local dy2 = y3 - y2
        local sx = x0 - x1 + x2 - x3
        local sy = y0 - y1 + y2 - y3
        local g = (sx * dy2 - dx2 * sy) / (dx1 * dy2 - dx2 * dy1)
        local h = (dx1 * sy - sx * dy1) / (dx1 * dy2 - dx2 * dy1)
        local a = x1 - x0 + g * x1
        local b = x3 - x0 + h * x3
        local c = x0
        local d = y1 - y0 + g * y1
        local e = y3 - y0 + h * y3
        local f = y0
        
        local mat = {0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0}
            
        mat[ 1] = a
        mat[ 2] = d
        mat[ 3] = 0
        mat[ 4] = g
        mat[ 5] = b
        mat[ 6] = e
        mat[ 7] = 0
        mat[ 8] = h
        mat[ 9] = 0
        mat[ 10] = 0
        mat[11] = 1
        mat[12] = 0
        mat[13] = c
        mat[14] = f    
        mat[15] = 0
        mat[16] = 1
        return mat
    end,
        
    computeQuadToSquare = function(self, inputdots)
        local x0 = inputdots[1][1]
        local y0 = inputdots[1][2]
        local x1 = inputdots[2][1]
        local y1 = inputdots[2][2]
        local x2 = inputdots[3][1]
        local y2 = inputdots[3][2]
        local x3 = inputdots[4][1]
        local y3 = inputdots[4][2]
        mat = self:computeSquareToQuad(inputdots);
        
        local a = mat[ 1]
        local d = mat[ 2]
        local g = mat[ 4]
        local b = mat[ 5]
        local e = mat[ 6]
        local h = mat[ 8]            
        local c = mat[13]
        local f = mat[14]
        
        local A = e - f * h
        local B = c * h - b
        local C = b * f - c * e
        local D = f * g - d
        local E =     a - c * g
        local F = c * d - a * f
        local G = d * h - e * g
        local H = b * g - a * h
        local I = a * e - b * d
        local idet = 1.0 / (a * A           + b * D           + c * G);
         
        mat[ 1] = A * idet
        mat[ 2] = D * idet
        mat[ 3] = 0
        mat[ 4] = G * idet
        
        mat[ 5] = B * idet
        mat[ 6] = E * idet
        mat[ 7] = 0
        mat[ 8] = H * idet
        
        mat[ 9] = 0       
        mat[ 10] = 0      
        mat[11] = 1
        mat[12] = 0      
        
        mat[13] = C * idet
        mat[14] = F * idet
        mat[15] = 0
        mat[16] = I * idet
        return mat
    end,
	
    multMats = function (self,srcMat,dstMat)
        local resMat = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
        for r=0,3 do
            local ri = r * 4;
            for c=1,4 do
                resMat[ri + c] = 
                  srcMat[ri + 1] * dstMat[c     ] + 
                  srcMat[ri + 2] * dstMat[c +  4] +    
                  srcMat[ri + 3] * dstMat[c +  8] + 
                  srcMat[ri + 4] * dstMat[c + 12];
            end
        end
        return resMat;
    end

}

return function ()
  local t = {
    srcmatrix = {0.0,0.0,1.0,0.0,0.0,1.0,1.0,1.0},
  	dstmatrix = {0.0,0.0,1.0,0.0,0.0,1.0,1.0,1.0},
  	dstdots = {{0.0,0.0},{1.0,0.0},{0.0,1.0},{1.0,1.0}},
  	srcdots = {{0.0,0.0},{1.0,0.0},{0.0,1.0},{1.0,1.0}},
  }
  
  return setmetatable(t,{
    __index = mt
  })
end
