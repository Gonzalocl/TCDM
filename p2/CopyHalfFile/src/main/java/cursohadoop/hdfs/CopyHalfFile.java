package cursohadoop.hdfs;

import java.net.URI;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IOUtils;

// TODO: Completar las instrucciones incompletas

public class CopyHalfFile {
	public static void main(String[] args) throws Exception {
		String src = args[0];
		String dst = args[1];
				
		// Configuracion por defecto
		Configuration conf = new Configuration();
		
		// Entrada
		Path pathin = new Path(src);
		// TODO: Crear un FileSystem para la entrada y un FSDataInputStream para leer los datos
		FileSystem fsin = FileSystem.get(URI.create(src),  conf);
		FSDataInputStream fin = null;

		// Salida
		Path pathout = new Path(dst);		
		// TODO: Crear un FileSystem para la salida y un FSDataInputStream para escribir los datos
		FileSystem fsout = FileSystem.get(URI.create(dst),  conf);
		FSDataOutputStream fout = null;
		
		try {
			// TODO: Crear un FileStatus del filesystem de entrada a partir del cual obtener la longitud
			FileStatus fileStatus = fsin.getFileStatus(pathin);
			long fileSize = fileStatus.getLen();

			// TODO: Abrir los FSDataInputStream y FSDataOutputStream
			fin = fsin.open(pathin);
			fout = fsout.open(pathout);

			// TODO: Saltar a la mitad de InputStream de entrada
			fin.seek(fileSize/2);

			// TODO: Copiar del InputStream al OutputStream
			IOUtils.copyBytes(fin, fout, conf, false);

		} finally {
			// TODO: Cerrar los streams
			IOUtils.closeStream(fin);
			IOUtils.closeStream(fout);

		}		
	}
}

