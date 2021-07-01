package cursohadoop.citationnumberbypatent_chained;

/**
 * Mapper Count Cites 
 * Para cada línea, obtiene la clave (patente) y cuenta el número de patentes que la citan
 */
import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;


public class CCMapper extends Mapper<Text, Text, Text, IntWritable> {
	// TODO: Completar el mapper
	@Override
	public void map(Text key, Text value, Context ctxt)
			throws IOException, InterruptedException {

		ctxt.write();
	}
}
