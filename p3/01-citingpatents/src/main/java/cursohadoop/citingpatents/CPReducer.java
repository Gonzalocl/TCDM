package cursohadoop.citingpatents;

/**
 * Reducer para CitingPatents - cites by number: Obtiene el número de citas de una patente
 * Para cada línea, obtiene la clave (patente) y une en un string el número de patentes que la citan
 */
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.io.Text;
import java.io.IOException;
import java.util.Iterator;


public class CPReducer extends Reducer<Text, Text, Text, Text> {
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
	public void reduce(Text key, Iterable<Text> values, Context context) throws IOException, InterruptedException {
		// TODO: Completad el reducer

		if (key.toString().equals("\"CITED\"")) {
			return;
		}

		StringBuilder resultValues = new StringBuilder();
		Iterator<Text> it = values.iterator();

		resultValues.append(it.next().toString());

		while (it.hasNext()) {
			resultValues.append(",").append(it.next().toString());
		}

		context.write(key, new Text(resultValues.toString()));
	}

}


