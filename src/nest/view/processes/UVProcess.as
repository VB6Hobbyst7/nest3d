package nest.view.processes 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	
	import nest.control.GlobalMethods;
	import nest.object.IMesh;
	import nest.view.Shader3D;
	
	/**
	 * UVProcess
	 */
	public class UVProcess implements IProcess {
		
		private var draw:Matrix3D;
		private var uvShader:Shader3D;
		
		public function UVProcess() {
			draw = new Matrix3D();
			uvShader = new Shader3D();
			uvShader.setFromString("m44 op, va0, vc0\nmov v0, va1" , "mov oc, v0", false);
		}
		
		public function doMesh(mesh:IMesh):void {
			var context3d:Context3D = GlobalMethods.context3d;
			
			draw.copyFrom(mesh.matrix);
			draw.append(GlobalMethods.camera.invertMatrix);
			draw.append(GlobalMethods.camera.pm);
			
			context3d.setCulling(mesh.culling);
			context3d.setBlendFactors(mesh.blendMode.source, mesh.blendMode.dest);
			context3d.setDepthTest(mesh.blendMode.depthMask, Context3DCompareMode.LESS);
			context3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, draw, true);
			
			mesh.data.upload(context3d, true, false);
			
			if (uvShader.changed) {
				uvShader.changed = false;
				if (!uvShader.program) uvShader.program = context3d.createProgram();
				uvShader.program.upload(uvShader.vertex, uvShader.fragment);
			}
			
			context3d.setProgram(uvShader.program);
			context3d.drawTriangles(mesh.data.indexBuffer);
			
			mesh.data.unload(context3d);
		}
		
	}

}