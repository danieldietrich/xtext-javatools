package net.danieldietrich.xtext.xtend2.javasupport.imports;

import java.util.Map;
import java.util.regex.Pattern;

import net.danieldietrich.xtext.xbase.jvmmodel.InferredJvmType;
import net.danieldietrich.xtext.xtend2.javasupport.JavaExtensions;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.common.types.JvmGenericType;
import org.eclipse.xtext.common.types.JvmType;
import org.eclipse.xtext.common.types.TypesFactory;
import org.eclipse.xtext.xbase.lib.Functions.Function1;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class ImportManager extends org.eclipse.xtext.xbase.compiler.ImportManager {

  // pattern for full qualified java names with Latin characters
  private static final Pattern FQN = Pattern.compile("([a-zA-Z_$][a-zA-Z\\d_$]*\\.)*[a-zA-Z_$][a-zA-Z\\d_$]*");
  
  // pattern for full qualified java names with Unicode characters (which are conform to the jvm specification)
  // private static final Pattern FQN = Pattern.compile("([\\p{L}_$][\\p{L}\\p{N}_$]*\\.)*[\\p{L}_$][\\p{L}\\p{N}_$]*");

  private static final TypesFactory typesFactory = TypesFactory.eINSTANCE; // TODO(@@dd): @Inject
  private static final JavaExtensions javaExtensions = new JavaExtensions(); // TODO(@@dd): @Inject
  
  private final String currentPackage;
  private final Map<Class<?>, Function1<Object,String>> converter;
  
  /**
   * Constructor
   *  
   * @param organizeImports true: import list will be created, false: full qualified names in output, only.
   * @param currentPackage Classes belonging to the current package will not be mentioned in the import list when calling one of the #appendType methods.
   */
  public ImportManager(String currentPackage, Map<Class<?>, Function1<Object,String>> converter) {
    super(true);
    this.currentPackage = (currentPackage == null) ? "" : currentPackage;
    this.converter = converter;
  }
  
  /**
   * Builds an appropriate type and calls super.appendType(type, builder).
   * If fqn is no regular full qualified java class name then fqn is the result.
   * Else if package of fqn is currentPackage, then return simple name.
   * Else create JvmType and return super.appendType(JvmType, StringBuilder).
   * 
   * @param fqn Full qualified name, not null
   * @param builder Here goes the output
   */
  public void appendType(String fqn, StringBuilder builder) {
    if (!FQN.matcher(fqn).matches()) {
      builder.append(fqn);
    } else {
      JvmGenericType type = typesFactory.createJvmGenericType();
      type.setPackageName(javaExtensions.packageName(fqn));
      type.setSimpleName(javaExtensions.simpleName(fqn));
      appendType(type, builder);
    }
  }
  
  /**
   * Omit package for types declared within currentPackage.
   * @see org.eclipse.xtext.xbase.compiler.ImportManager#appendType(JvmType, StringBuilder)
   */
  @Override
  public void appendType(final JvmType type, StringBuilder builder) {
    if (type instanceof InferredJvmType && converter != null) {
      EObject node = ((InferredJvmType<?>) type).getModelElement();
      Class<?> nodeType = node.getClass().getInterfaces()[0]; // TODO(@@dd): *DIRTY* - assuming here, that the node is a class which implements exactly one interface which is the grammar element
      Function1<Object,String> transformation = converter.get(nodeType);
      if (transformation != null) {
        appendType(transformation.apply(node), builder);
      } else {
        super.appendType(type, builder);
      }
    } else {
      if (currentPackage.equals(javaExtensions.packageName(type.getQualifiedName()))) {
        builder.append(type.getSimpleName());
      } else {
        super.appendType(type, builder);
      }
    }
  }
  
}
