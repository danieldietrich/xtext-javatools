package net.danieldietrich.xtext.generator;

import java.io.File;
import java.io.FileFilter;
import java.io.FileNotFoundException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.util.Files;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.IResourceValidator;
import org.eclipse.xtext.validation.Issue;

import com.google.inject.Inject;
import com.google.inject.Provider;

/**
 * Given a Xtext project StandaloneGenerator is useful to easily setup and run a java standalone generator.<br>
 * <br>
 * Beside your Xtend2 generator create a Main class as follows:
 * <pre>
 * public class Main {
 * 
 *   public static void main(String[] args) {
 *   
 *     <em>// create instance using Injector</em>
 *     Injector injector = new YourStandaloneSetupGenerated().createInjectorAndDoEMFRegistration();
 *     StandaloneGenerator generator = injector.getInstance(StandaloneGenerator.class);
 *   
 *     <em>// (optional) configure this...</em>
 *     generator.setOutputPath("src-gen", null, true);
 *     
 *     <em>// (optional) ...or that</em>
 *     generator.addSlot("gen", "src-gen", null, true);
 *     generator.addSlot("once", "src-once", null, false);
 *     generator.addSlot("special1", "src-special/dir1", null, true);
 *     generator.addSlot("special2", "src-special/dir2", null, true);
 *   
 *     <em>// run generator</em>
 *     generator.run(args);
 *   }
 * }
 * </pre>
 * 
 * It is a good practice to create a separate project with concrete models. Here you call:
 * <pre>
 * Main.main(new String[] { "./path/to/your1st.model", "./path/to/your2nd.model" });
 * </pre>
 * 
 * After generating the first time source folders have to be adjusted in your ide.<br>
 * <br>
 * 
 * @author Daniel Dietrich - Initial contribution and API
 */
public class StandaloneGenerator {

  private final Logger logger = Logger.getLogger(StandaloneGenerator.class.getName());
  
  @Inject 
  private Provider<ResourceSet> resourceSetProvider;
  
  @Inject
  private IResourceValidator validator;
  
  @Inject
  private IGenerator generator;
  
  @Inject
  private JavaIoFileSystemAccess fileAccess;

  private List<Slot> slots = new ArrayList<Slot>();

  /** please get an instance via guice injection */
  StandaloneGenerator() {
  }
  
  /**
   * Configure slots (= named directories) to write files into.
   * {@link org.eclipse.xtext.generator.IFileSystemAccess#generateFile(String fileName, String slot, CharSequence contents)}
   * 
   * @param name
   * @param path
   * @param filter
   * @param clean
   */
  public void addSlot(String name, String path, FileFilter filter, boolean clean, boolean overwrite) {
    slots.add(new Slot(name, new File(path), filter, clean, overwrite));
  }
  
  /**
   * Configure default output path (needed when not using a slot).
   * {@link org.eclipse.xtext.generator.IFileSystemAccess#generateFile(String fileName, CharSequence contents)}
   * 
   * @param outputPath
   * @param filter
   * @param clean
   */
  public void setOutputPath(String outputPath, FileFilter filter, boolean clean, boolean overwrite) {
    slots.add(new Slot(null, new File(outputPath), filter, clean, overwrite));
  }
  
  /**
   * Runs the generator for each model after cleaning directories.
   * @param models paths to model files
   */
  public void run(String[] models) {
    try {
      generate(models);
    } catch(RuntimeException x) {
      logger.log(Level.SEVERE, "", x);
      throw x;
    }
  }
  
  /**
   * Check arguments, clean dirs and generate each model resource.
   * 
   * @param models
   */
  private void generate(String[] models) {

    long start = System.currentTimeMillis();
    
    if (models == null || models.length==0) {
      throw new IllegalArgumentException("Aborting: no path to EMF resource provided!");
    }
    
    if (slots.size() == 0) {
      throw new IllegalStateException("No output path(s) specified. please set outputPath and/or add slots.");
    }

    try {
      cleanDirs();
    } catch (FileNotFoundException x) {
      logger.warning("Error cleaning folders.");
    }
    
    for (String model : models) {
      generate(model);
    }
    
    BigDecimal time = new BigDecimal(String.valueOf((System.currentTimeMillis() - start)/1000.0d)).setScale(1, BigDecimal.ROUND_DOWN);
    logger.log(Level.INFO, "Successfully finished code generation in " + time.toPlainString() + " sec.");
  }
  
  /**
   * Generate a model resource.
   * 
   * @param model
   */
  private void generate(String model) {
    
    
    // load the resource
    ResourceSet set = resourceSetProvider.get();
    Resource resource = set.getResource(URI.createURI(model), true);
    
    // validate the resource
    List<Issue> list = validator.validate(resource, CheckMode.ALL, CancelIndicator.NullImpl);
    if (!list.isEmpty()) {
      for (Issue issue : list) {
        logger.log(Level.SEVERE, "Validation issue: " + ((issue == null) ? null : issue.toString()));
      }
      return;
    }

    // configure the generator
    for (Slot slot : slots) {
      if (slot.name == null) {
        logger.fine("Setting output path '" + slot.path.getPath() + "'");
        fileAccess.setOutputPath(slot.path.getPath());
      } else {
        logger.fine("Adding slot '" + slot.name + "' -> '" + slot.path.getPath() + "'");
        fileAccess.setOutputPath(slot.name, slot.path.getPath());
      }
    }
    
    // start the generator
    logger.info("Generating files...");
    generator.doGenerate(resource, fileAccess);
  }
  
  /**
   * Clean directories (i.e. all slots, including default slot).
   * 
   * @throws FileNotFoundException
   */
  private void cleanDirs() throws FileNotFoundException {
    for (Slot slot : slots) {
      if (slot.clean) {
        logger.info("Cleaning folder " + slot.path.getPath());
        Files.cleanFolder(slot.path, slot.filter, true, false);
      }
    }
  }
  
  /**
   * Slot represents a named, cleanable output path.
   */
  private static class Slot {
    final String name;
    final File path;
    final FileFilter filter;
    final boolean clean;
    final boolean overwrite;
    Slot(String name, File path, FileFilter filter, boolean clean, boolean overwrite) {
      this.name = name;
      this.path = path;
      this.filter = filter;
      this.clean = clean;
      this.overwrite = overwrite;
    }
  }
  
}
