package cursohadoop.citingpatents;

/**
 * Reducer para CitingPatents - cites by number: Obtiene el número de citas de una patente
 * Para cada línea, obtiene la clave (patente) y une en un string el número de patentes que la citan
 */
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.io.Text;
import java.io.IOException;


public class CPReducer extends Reducer<  > {
	/**
	 * Método reduce
	 * @param key Patente citada
	 * @param values Lista con las patentes que la citan
	 * @param context Contexto MapReduce
	 * @throws IOException
	 * @throws InterruptedException
	 */
	// TODO: Completar el reducer
	@Override
	public void reduce(  ) throws IOException, InterruptedException {
		// TODO: Completad el reducer

		context.write(key, );
	}

}


