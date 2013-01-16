import net.danieldietrich.xtext.generator.StandaloneGenerator;

import com.gwtarchetype.dsl.domainmodel.generator.GeneratorFactory;


public class Main {

  public static void main(String[] args) {
    
    StandaloneGenerator generator = GeneratorFactory.createGenerator();

    generator.addSlot("client-gen", "client-gen", null, false, false);
    generator.addSlot("server-gen", "server-gen", null, false, false);
    
    // run generator
    generator.run(new String[] { "./src/example.dmodel" });

  }
  
}
