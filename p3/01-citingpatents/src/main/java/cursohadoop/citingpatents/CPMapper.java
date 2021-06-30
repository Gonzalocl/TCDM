package cursohadoop.citingpatents;

/**
 * Mapper para CitingPatents - cites by number: Obtiene el número de citas de una patente
 * Para cada línea, invierte las columnas (patente citada, patente que cita)
 */
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.io.Text;
import java.io.IOException;

public class CPMapper extends Mapper<Text, Text, Text, Text> {
	/*
	 * Método map
	 * @param key patente que cita
	 * @param value patente citada
	 * @param context Contexto MapReduce
	 * @throws IOException
	 * 
	 * @see org.apache.hadoop.mapreduce.Mapper#map(KEYIN, VALUEIN,
	 * org.apache.hadoop.mapreduce.Mapper.Context)
	 */
	// TODO: Completar el mapper
	@Override
	public void map(Text key, Text value, Context ctx) throws IOException, InterruptedException {
		ctx.write(value, key);
	}
}
