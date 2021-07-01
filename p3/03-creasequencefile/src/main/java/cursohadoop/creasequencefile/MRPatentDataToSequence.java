package cursohadoop.creasequencefile;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

/**
    Programa MapReduce MapOnly (sin reducers) que lea el fichero apat63_99.txt, separe los campos y lo guarde como un fichero Sequence (formato clave/valor) con

    clave: el país (en formato Text, y sin comillas)
    valor: una cadena (Text) con la patente y el año separados por coma, sin espacios en blanco
*/

public class MRPatentDataToSequence extends Configured implements Tool {
  // Tamano en bytes de la primera linea del fichero apat, para saltarnosla
  private static long bytes_primera_linea = 225;

  @Override
  public int run(String[] arg0) throws Exception {
    // Crea el job
    Job job = creaJob(this, getConf(), arg0);
    if (job == null) {
      return -1;
    }
    job.setJobName("Crea fichero sequence");

    //TODO: Especifica el formato de la entrada y la salida
    job.setInputFormatClass(TextInputFormat.class);
    job.setOutputFormatClass(SequenceFileOutputFormat.class);

    //TODO: Especifica los tipos de salida del mapper y final
    job.setMapOutputKeyClass(Text.class);
    job.setMapOutputValueClass(Text.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(Text.class);

    job.setMapperClass(MRPatentDataToSequenceMapper.class);

    //TODO: Especifica 0 tareas reduce
    job.setNumReduceTasks(0);

    return job.waitForCompletion(true) ? 0 : 1;
  }

  public static void main(String[] args) throws Exception {
    int exitCode = ToolRunner.run(new MRPatentDataToSequence(), args);
    System.exit(exitCode);
  }

  static class MRPatentDataToSequenceMapper extends
      Mapper<LongWritable, Text, Text, Text> {

    // TODO: Completa lo que falta para obtener el nombre del fichero que está en la cache
    @Override
    public void setup(Context context) throws IOException,
        InterruptedException {
      Configuration conf = context.getConfiguration();
      Path ccPath = new Path(Job.getInstance(conf).getCacheFiles()[0].getPath());
      String ccFileName = ccPath.toString();
      parseCCFile(ccFileName);
    }

    // TODO: Completar el mapper
    @Override
    protected void map(LongWritable key, Text value, Context context)
        throws IOException, InterruptedException {
      // TODO: El if debe ser cierto excepto para la primera línea
      if (key.get() > bytes_primera_linea) {
        // Separamos la linea en campos
        String[] fields = value.toString().split(",");
        // Escribimos el pais (eliminando las comillas)
        Text pais = new Text(fields[4].replace("\"", ""));
        // Escribimos la patente y el anho
        Text patenteanho = new Text(fields[0] + "," + fields[1]);
        // TODO: Completa la alida del mapper.
        // countryInfo es un Map que nos devuelve el nombre del país a partir de su código.
        context.write(pais, patenteanho);
      }
    }

    // Método para leer el fichero contry_codes.txt y convertirlo en un Map Java
    private void parseCCFile(String ccFileName) {
      BufferedReader fis;
      try{
        fis = new BufferedReader(new FileReader(ccFileName));
        String[] linea;
        while(fis.ready()) {
          linea = fis.readLine().split("\t");
          countryInfo.put(new Text(linea[0]), new Text(linea[1]));
        }
      } catch (IOException ioe) {
          System.err.println("Error parseando el fichero country_codes.txt ");
          ioe.printStackTrace();
      }
    }

    private Map<Text,Text> countryInfo = new HashMap<Text,Text>();
  }

  private Job creaJob(Tool tool, Configuration conf, String[] args)
      throws IOException {
    /* Comprueba los parámetros de entrada */
    if (args.length != 2) {
      System.err
        .printf("Usar: %s [opciones genéricas] <directorio_entrada> <directorio_salida>%n",
              getClass().getSimpleName());
      System.err
        .printf("Recuerda que el directorio de salida no puede existir");
      ToolRunner.printGenericCommandUsage(System.err);
      return null;
    }

    /* Obtiene un job a partir de la configuración actual */
    Job job = Job.getInstance(conf);

    /* Fija el jar del trabajo a partir de la clase del objeto actual */
    job.setJarByClass(tool.getClass());

    /* Añade al job los paths de entrada y salida */
    FileInputFormat.addInputPath(job, new Path(args[0]));
    FileOutputFormat.setOutputPath(job, new Path(args[1]));

    return job;
  }
}
