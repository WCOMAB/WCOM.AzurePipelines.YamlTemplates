namespace library.tests;

public class Tests
{
    [SetUp]
    public void Setup()
    {
    }

    [Test]
    public void Test1()
    {
        // Given
        Class1 class1 = new ();

        // When
        var result = class1.Method1();

        // Then

        Assert.That(result, Is.EqualTo("Hello from library"));
    }
}