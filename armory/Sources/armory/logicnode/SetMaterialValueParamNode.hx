package armory.logicnode;

import iron.Scene;
import iron.data.MaterialData;
import iron.object.Object;
import armory.trait.internal.UniformsManager;
import haxe.Timer;
import haxe.ds.StringMap;

class SetMaterialValueParamNode extends LogicNode {

    // Guardar últimos valores por material// 
    static var lastValues: StringMap<Float> = new StringMap<Float>();

    public function new(tree: LogicTree) {
        super(tree);
    }

    override function run(from: Int) {
        var object: Object = inputs[1].get();
        if(object == null) return;

        var perObject: Null<Bool> = inputs[2].get();
        if(perObject == null) perObject = false;

        var mat: MaterialData = inputs[3].get();
        if(mat == null) return;

        var link: String = inputs[4].get();
        if(link == null) return;

        // tomo el valor del material
        var value: Float = 0.0;
        if (inputs.length > 5) value = inputs[5].get();
        if (value == null) return;


       	// tomo el valor de "step" para modificar la duracion en la transicion...
        var duration: Float = 0.0;
        if (inputs.length > 6) {
            var d = inputs[6].get();
            if (d != null && d > 0) duration = d;
        }

        if (!perObject) {
            UniformsManager.removeFloatValue(object, mat, link);
            object = Scene.active.root;
        }

        // guardo una "ID" para cada material y object (asi la puedo usar para el ultimo valor y no reestablecerlo desde 0 al transicionar a otros valores) 
        // (un ejemplo seria trasicionar de 0.200 a 0.600 con la misma tecla)

        var key = object.name + "_" + mat.name + "_" + link;
        var current: Float = 1.0;
        if (lastValues.exists(key)) current = lastValues.get(key);

        if (Math.abs(value - current) < 0.0001) {
            runOutput(0);
            return;
        }

        var steps: Int = 60;
        var stepTime: Float = duration / steps;
        var delta: Float = (value - current) / steps;

        for (i in 0...steps) {
            Timer.delay(function() {
                current += delta;
                if (current < 0) current = 0;
                if (current > 1) current = 1;
                UniformsManager.setFloatValue(mat, object, link, current);
                lastValues.set(key, current);
            }, Std.int(stepTime * 1000 * i));
        }

        runOutput(0);
    }
}

